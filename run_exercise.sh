#!/bin/bash

# TODO adjust README of Charon

# "Parse" mode argument
mode="$1"
if [ "$mode" == "maven" ]; then
	exercise_folders_to_setup[0]="target"
elif [ "$mode" == "gradle" ]; then
	exercise_folders_to_setup[0]=".gradle"
	exercise_folders_to_setup[1]="build"
elif [ "$mode" == "" ]; then
	echo "Usage: $0 <mode>"
	echo "Mode can be \"maven\" or \"gradle\""
	exit 1
else
	echo "Unknown mode: $mode"
	echo "Mode can be \"maven\" or \"gradle\""
	exit 1
fi
exercise_image="exercise-$mode"
exercise_compile_command="./compile_$mode.sh"
exercise_run_command="./run_$mode.sh"

# Setup logging utilities
prepend_log_exec() {
	exec sed -u "s/^/$1/"
}

logging_prefix_size=12

logprefix() {
	exec printf "[%-${logging_prefix_size}s] " "$1"
}

logging_err_only() {
	prefix=$(logprefix "$1")
	shift
	"$@" \
		2> >(prepend_log_exec "$prefix" >&2)
}

logging_out_no_procsubst() {
	prefix=$(logprefix "$1")
	shift
	"$@" | prepend_log_exec "$prefix"
}


logging() {
	prefix=$(logprefix "$1")
	shift
	"$@" \
		 > >(prepend_log_exec "$prefix") \
		2> >(prepend_log_exec "$prefix" >&2)
}

logmeta() {
	logging_out_no_procsubst "META" echo "$@"
}

errmeta() {
	logmeta "$@" >&2
}

error_and_exit() {
	exit_code=$1
	shift
	errmeta "$@"
	exit $exit_code
}

# Setup cleanup utilities

cleanup_student() {
	if [ "$student_container_name" == "" ]; then
		logmeta "Not cleaning up student side container because it wasn't started yet"
	else
		# Remove student container
		# On error, echo student container name in case somebody wants to cleanup "by hand".
		logging "STUD REMOVE" docker rm -f "$student_container_name" >/dev/null \
		|| error_and_exit $? "Removing student container failed with $?. This means it might still be running! Student container name: $exercise_container_name"
	fi
}

cleanup_exercise_ownership() {
	# Fix exercise ownership
	./fix_exercise_ownership.sh \
	|| error_and_exit $? "Fixing exercise ownership failed with $?"
}

cleanup_exercise_container() {
	if [ "$exercise_container_name" == "" ]; then
		logmeta "Not cleaning up exercise side container because it wasn't started yet"
	else
		# Remove exercise container
		# On error, echo exercise container name in case somebody wants to cleanup "by hand"
		logging "EXER REMOVE" docker rm -f "$exercise_container_name" >/dev/null \
		|| error_and_exit $? "Removing exercise container failed with $?. Exercise container name: $exercise_container_name"
	fi
}

cleanup() {
	# Kill timeout job if it still exists
	if [ "$timeout_pid" != "" ]; then
		# Ignore errors on kill
		kill $timeout_pid >/dev/null 2>/dev/null
	fi
	# Subshell for each cleanup part to execute subsequent cleanups even if one part calls exit
	cleanup_exit_code=0
	(cleanup_exercise_container) || cleanup_exit_code=$?
	(cleanup_exercise_ownership) || cleanup_exit_code=$?
	(cleanup_student) || cleanup_exit_code=$?
	if [ $cleanup_exit_code != 0 ]; then exit $cleanup_exit_code; fi
}

cleanup_trap() {
	logmeta "Cleaning up..."
	cleanup
	logmeta "Cleanup completed successfully"
}

trap cleanup_trap EXIT

term_int_trap() {
	sigterm_int_exitcode=$?
	# This only happens in some very weird edge cases,
	# for example if the interrupt occurs during a "docker run" command.
	if [ $sigterm_int_exitcode == 0 ]; then
		sigterm_int_exitcode=143
	fi
	logmeta "Interrupted"
	# No need to remove containers; that will be done by the cleanup functions.
	exit $sigterm_int_exitcode
}

# This makes the script more robust against SIGINT (Ctrl+C) and SIGTERM:
# Without this, if the script gets SIGINT or SIGTERM during a "docker run",
# the container ID would not get saved to the corresponding variable,
# so the cleanup would not be able to stop the container.
trap term_int_trap TERM INT

# Setup timeout
if [ "$TIMEOUT" != "" ]; then
	sigusr1_trap() {
		sigusr1_exitcode=$?
		# This only happens in some very weird edge cases,
		# for example if the timeout occurs during a "docker run" command.
		if [ $sigusr1_exitcode == 0 ]; then
			sigusr1_exitcode=138
		fi
		logmeta "Timeout triggered"
		if [ "$TIMEOUT_EXER_EXTRA" != "" ]; then
			if [ "$student_container_name" == "" ]; then
				logmeta "Not killing student container because it wasn't started yet"
			else
				if [ "$student_copy_pid" != "" ]; then
					logmeta "Killing student copy process"
					logging "TIMEOUT STUD" kill -SIGKILL $student_copy_pid
				fi
				logmeta "Killing student container"
				logging_err_only "TIMEOUT STUD" docker kill $student_container_name >/dev/null
			fi
			logmeta "Giving exercise side time to clean up..."
			sleep "$TIMEOUT_EXER_EXTRA"
		fi
		# No need to remove containers; that will be done by the cleanup functions.
		exit $sigusr1_exitcode
	}

	trap sigusr1_trap SIGUSR1

	mainscriptpid=$$
	{
		# Only send signal if the sleep succeeded, because when pressing Ctrl+C,
		# this sleep will be interrupted as well, but then we don't want to cause a timeout.
		sleep "$TIMEOUT" &&
		kill -SIGUSR1 $mainscriptpid
	} &
	timeout_pid=$!
fi

# Setup common. This will also parse STUDENT_SIDE_SOURCES, if set.
logging "META" ./setup_common.sh \
|| error_and_exit $? "Setting up failed with $?"

# Run student container, but don't do anything yet.
student_container_name=$(logging_err_only "STUD START" docker run \
		--detach \
		--volume $(readlink -f fifos):/fifos \
		--network none \
		$ADDITIONAL_DOCKER_ARGS_STUDENT \
		ghcr.io/haspamelodica/charon:student \
		bash -c 'while true; do sleep 10; done') \
|| {
	exit_code=$?
	errmeta "Starting student container failed with $exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so don't exit on errors there.
	logging "STUD REMOVE" docker rm -f "$student_container_name" >/dev/null 2>/dev/null \
	|| logmeta "Removing student container failed with $?; it probably wasn't started at all."

	# Don't try to continue
	exit $exit_code
}

# Copy over student-side files
# Note: The dot following the source is important; see the documentation of docker cp.
logging "STUD COPY" exec docker cp student/. "$student_container_name":/data/ &
#TODO this is not the PID of docker cp
student_copy_pid=$!
# Run in background and immediately wait to make sure Ctrl+C and timeout works
wait $student_copy_pid\
|| error_and_exit $? "Copying student files failed with $?"
unset student_copy_pid

# Start compiling student side
logging "STUD COMPILE" docker exec "$student_container_name" ./compile.sh &
student_compile_pid=$!

# Setup exercise
logging "META" ./setup_exercise.sh "${exercise_folders_to_setup[@]}" \
|| error_and_exit $? "Setting up exercise failed with $?"

# Run exercise container, but don't do anything yet.
exercise_container_name=$(logging_err_only "EXER START" docker run \
		--detach \
		--volume $(readlink -f exercise):/data \
		--volume $(readlink -f fifos):/fifos \
		$ADDITIONAL_DOCKER_ARGS_EXERCISE \
		ghcr.io/haspamelodica/charon:"$exercise_image" \
		bash -c 'while true; do sleep 10; done') \
|| {
	exit_code=$?
	errmeta "Starting exercise container failed with $exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so don't fail on errors there.
	docker rm -f "$exercise_container_name" >/dev/null 2>/dev/null \
	|| logmeta "Removing exercise container failed with $?; it probably wasn't started at all."

	# Don't try to continue
	exit $exit_code
}

# Compile the exercise side
logging "EXER COMPILE" docker exec \
		"$exercise_container_name" \
		$exercise_compile_command &
exercise_compile_pid=$!
# Run in background and immediately wait to make sure Ctrl+C and timeout works
wait $exercise_compile_pid \
|| error_and_exit $? "Compiling exercise side failed with $?"

# Wait for student compilation to finish
wait $student_compile_pid \
|| error_and_exit $? "Compiling student side failed with $?"

logging "STUD RUN" docker exec \
		"$student_container_name" \
		./run.sh &
# No need to save PID; we don't want to wait for the student side anyway.

exit_code_exercise=0
# Run exercise container
logging "EXER RUN" docker exec \
		"$exercise_container_name" \
		$exercise_run_command &
exercise_run_pid=$!
# Run in background and immediately wait to make sure Ctrl+C and timeout works
# Erroring here is normal, it happens if the student doesn't pass all tests.
wait $exercise_run_pid \
|| error_and_exit $? "Exercise container finished with $?"

# Don't wait for the student container to exit.
# Also don't kill it here, it'll be killed by the cleanup either way.

# Done, and all tests successful!
logmeta "Exercise container finished successfully!"
