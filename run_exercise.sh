#!/bin/bash

# Setup exercise
./setup_exercise.sh || exit $?

# Run student container
student_container_name=$(docker run \
		--volume $(readlink -f fifos):/fifos \
		--detach \
		$ADDITIONAL_DOCKER_ARGS_STUDENT \
		charon:student) \
|| {
	student_exit_code=$?
	echo "Starting student container failed with $student_exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so ignore errors there.
	docker rm -f "$student_container_name" || (echo "Removing student container failed with $?; it probably wasn't started at all." >&2)

	# Don't try to continue
	exit $student_exit_code
}

exit_code=0

# Run exercise container
docker run \
		--volume $(readlink -f exercise):/data \
		--volume $(readlink -f fifos):/fifos \
		--rm \
		$ADDITIONAL_DOCKER_ARGS_EXERCISE \
		ghcr.io/haspamelodica/charon:exercise \
|| {
	exit_code=$?
	echo "Exercise container failed with $exit_code" >&2
}

# Fix exercise ownership
./fix_exercise_ownership.sh \
|| {
	# Overwrite previous error code from exercise container
	exit_code=$?
	echo "Fixing exercise ownership failed with $exit_code" >&2
}

# Stop student container. Don't remove it yet; first cat logs.
# Also, ignore any errors and pipe stderr to /dev/null:
# docker stop fails if the container shut down by itself,
# and we remove the container later on either way.
docker stop "$student_container_name" 2>/dev/null

# Cat student logs so they appear in regular log.
./cat_student_logs.sh "$student_container_name" \
|| {
	# Don't overwrite previous error codes
	exit_code_cat=$?
	if [ "$exit_code" == "0" ]; then exit_code=$exit_code_cat; fi
	echo "Cat student logs failed with $exit_code_cat" >&2
}

# Remove student container
docker rm -f "$student_container_name" \
|| {
	# Overwrite previous error codes
	exit_code=$?
	echo "Removing student container failed with $exit_code. This means it might still be running!" >&2
	# Echo student container name in case somebody wants to cleanup "by hand"
	echo "Student container name: $student_container_name" >&2
}

exit $exit_code
