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

if [ "$TIMEOUT" != "" ]; then
	_timeout() {
		timeout -vk "$TIMEOUT" "$TIMEOUT" "$@"
	}
else
	_timeout() {
		"$@"
	}
fi

docker_with_timeout() {
	_timeout docker "$@"
}

# Setup logging and cleanup utilities
prepend_log_exec() {
	exec sed -u "s/^/$1/"
}

logging_prefix_size=12

logging_err_only() {
	prefix=$(printf "%-${logging_prefix_size}s" "$1")
	shift
	"$@" \
		2> >(prepend_log_exec "[$prefix] " >&2)
}

logging() {
	prefix=$(printf "%-${logging_prefix_size}s" "$1")
	shift
	"$@" \
		 > >(prepend_log_exec "[$prefix] ") \
		2> >(prepend_log_exec "[$prefix] " >&2)
}

error() {
	logging "META" echo "$@" >&2
}

cleanup() {
	: # nothing to do for now; will get redefined later
}

cleanup_trap() {
	logging "META" echo "Cleaning up..."
	cleanup
}

trap cleanup_trap EXIT

error_and_exit() {
	exit_code=$1
	shift
	error "$@"
	exit $exit_code
}

# Setup common
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
	error "Starting student container failed with $exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so don't exit on errors there.
	logging "STUD REMOVE" docker rm -f "$student_container_name" >/dev/null 2>/dev/null \
	|| error "Removing student container failed with $?; it probably wasn't started at all."

	# Don't try to continue
	exit $exit_code
}

cleanup_student() {
	# Remove student container
	# On error, echo student container name in case somebody wants to cleanup "by hand".
	logging "STUD REMOVE" docker rm -f "$student_container_name" >/dev/null \
	|| error_and_exit $? "Removing student container failed with $?. This means it might still be running! Student container name: $exercise_container_name"
}

cleanup() {
	# Subshell for each cleanup part to execute subsequent cleanups even if one part calls exit
	cleanup_exit_code=0
	(cleanup_student) || cleanup_exit_code=$?
	if [ $cleanup_exit_code != 0 ]; then exit $cleanup_exit_code; fi
}

# Copy over student-side files
# Note: The dot following the source is important; see the documentation of docker cp.
logging "STUD COPY" docker_with_timeout cp student/. "$student_container_name":/data/ \
|| error_and_exit $? "Copying student files failed with $?"

# Start compiling student side
logging "STUD COMPILE" docker_with_timeout exec "$student_container_name" ./compile.sh &
student_compile_pid=$!

# Setup exercise
logging "META" ./setup_exercise.sh "${exercise_folders_to_setup[@]}" \
|| error_and_exit $? "Setting up exercise failed with $?"

cleanup_exercise_ownership() {
	# Fix exercise ownership
	./fix_exercise_ownership.sh \
	|| error_and_exit $? "Fixing exercise ownership failed with $?"
}

cleanup() {
	# Subshell for each cleanup part to execute subsequent cleanups even if one part calls exit
	cleanup_exit_code=0
	(cleanup_exercise_ownership) || cleanup_exit_code=$?
	(cleanup_student) || cleanup_exit_code=$?
	if [ $cleanup_exit_code != 0 ]; then exit $cleanup_exit_code; fi
}

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
	error "Starting exercise container failed with $exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so don't fail on errors there.
	docker rm -f "$exercise_container_name" >/dev/null 2>/dev/null \
	|| error "Removing exercise container failed with $?; it probably wasn't started at all."

	# Don't try to continue
	exit $exit_code
}

cleanup_exercise_container() {
	# Remove exercise container
	# On error, echo student container name in case somebody wants to cleanup "by hand"
	logging "EXER REMOVE" docker rm -f "$exercise_container_name" >/dev/null \
	|| error_and_exit $? "Removing exercise container failed with $?. Exercise container name: $exercise_container_name"
}

cleanup() {
	# Subshell for each cleanup part to execute subsequent cleanups even if one part calls exit
	cleanup_exit_code=0
	(cleanup_exercise_container) || cleanup_exit_code=$?
	(cleanup_exercise_ownership) || cleanup_exit_code=$?
	(cleanup_student) || cleanup_exit_code=$?
	if [ $cleanup_exit_code != 0 ]; then exit $cleanup_exit_code; fi
}

# Compile the exercise side
logging "EXER COMPILE" docker_with_timeout exec \
		"$exercise_container_name" \
		$exercise_compile_command \
|| error_and_exit $? "Compiling exercise side failed with $?"

# Wait for student compilation to finish
wait $student_compile_pid \
|| error_and_exit $? "Compiling student side failed with $?"

# No timeout neccessary; we kill the student later either way
logging "STUD RUN" docker exec \
		"$student_container_name" \
		./run.sh &
# No need to save PID; we don't want to wait for the student side anyway.

exit_code_exercise=0
# Run exercise container
# Erroring here is normal, it happens if the student doesn't pass all tests.
logging "EXER RUN" docker_with_timeout exec \
		"$exercise_container_name" \
		$exercise_run_command \
|| error_and_exit $? "Exercise container finished with $?"

# Don't wait for the student container to exit.

# Done, and all tests successful!
logging "META" echo "Exercise container finished successfully!"
