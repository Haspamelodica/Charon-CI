#!/bin/bash

# Setup exercise
./setup_exercise.sh || exit $?

# Run student container
docker run \
		--volume $(readlink -f student/logs):/logs \
		--volume $(readlink -f fifos):/fifos \
		--detach \
		--name studentcodeseparator-student \
		studentcodeseparator:student \
|| {
	student_exit_code=$?
	echo "Starting student container failed with $student_exit_code"

	# Still try to stop it in case it was started even if docker run reported an error. Probably fails, so ignore errors there.
	docker rm -f studentcodeseparator-student || (echo "Removing student container failed with $?; it probably wasn't started at all." >&2)

	# Don't try to continue
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
	echo "Exercise container failed with $exit_code" >&2
}

# Fix exercise ownership
./fix_exercise_ownership.sh \
|| {
	# Overwrite previous error code from exercise container
	exit_code=$?
	echo "Fixing exercise ownership failed with $exit_code" >&2
}

# Kill student container. Don't remove it yet; first cat logs.
docker kill studentcodeseparator-student \
|| {
	# Overwrite previous error codes
	exit_code=$?
	echo "Killing student container failed with $exit_code. This means it might still be running!" >&2
}

# Cat student log files so they appear in regular log.
./cat_student_logs.sh \
|| {
	# Don't overwrite previous error codes
	exit_code_cat=$?
	if [ "$exit_code" == "0" ]; then exit_code=$exit_code_cat; fi
	echo "Cat student log files failed with $exit_code_cat" >&2
}

# Remove student container
docker rm -f studentcodeseparator-student \
|| {
	# Overwrite previous error codes
	exit_code=$?
	echo "Removing student container failed with $exit_code. This means it might still be running!" >&2
}

exit $exit_code
