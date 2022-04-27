#!/bin/bash

# Exit on first error
set -e

# Setup exercise
./setup_exercise.sh

# Run student container
docker run \
		--volume $(readlink -f student/logs):/logs \
		--volume $(readlink -f fifos):/fifos \
		--detach \
		--name studentcodeseparator-student \
		studentcodeseparator:student \
|| {
	student_exit_code=$?
	echo "Starting student container failed with $student_container_result"
	# Still try to stop it. Probably fails, so ignore errors there.
	docker rm -f studentcodeseparator-student || (echo "Removing student container failed with $?; it probably wasn't started at all." >&2)
	exit $student_exit_code
}

exit_code=0

# Run exercise container
docker run \
		--volume $(readlink -f exercise):/data \
		--volume $(readlink -f fifos):/fifos \
		--rm \
		studentcodeseparator:exercise \
|| {
	exit_code=$?
	echo "Exercise container failed with $exit_code"
}

# Fix exercise ownership
./fix_exercise_ownership.sh \
|| {
	# Overwrite previous exit codes
	exit_code=$?
	echo "Fixing exercise ownership failed with $exit_code"
}

# Kill and remove student container
docker rm -f studentcodeseparator-student \
|| {
	# Overwrite previous exit codes
	exit_code=$?
	echo "Removing student container failed with $student_container_kill_result. This means it might still be running!" >&2
}

exit $exit_code
