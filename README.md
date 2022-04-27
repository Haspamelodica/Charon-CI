# StudentCodeSeparator for CI
This repository makes using the StudentCodeSeparator easier for CI systems.

It requires two repositories to be cloned into subfolders by the CI system;
the "student submission" repository containing all files submitted by the student,
and the "tests" containing all files created by the exercise creator.

No files from the tests repository will be (directly) visible to student code.
Additionally, no files from the student submission repository will be (directly) visible to test code by default,
which is to prevent accidental security bugs.

When used with the recommended pipeline, the `test` goal of a POM file in the tests repository
will be invoked with the `studentcodeseparator` system property set correctly for communicating with the student side.

## Requirements

### Build environment
- The build environment must have Docker preinstalled.

### Student submissions repository
- All sources must be in one folder called `src` at repository root.

### Tests repository
- There must be a POM file at the repository root.
  This POM file may use any Maven plugins and dependencies, but using
  `org.apache.maven.plugins:maven-surefire-plugin:3.0.0-M6` and `org.junit.jupiter:junit-jupiter-engine:5.8.2`
  is recommended because those two artifacts are pre-cached in the exercise container.

## Recommended pipeline for testing student submissions
 1. Clone this repo.
 2. Execute `setup_containers.sh`.
     Step 1 has to be finished for this to work.
 3. (Optional) To delete all files from old student submissions and tests, execute `clean.sh`.
     Step 2 has to be finished for this to work.
 4. Clone / check out exercise-specific repositories: student submission to `student/assignment`, tests to `exercise/tests`.
     Step 3, if used, has to be finished for this to work.
 5. Execute `setup_exercise.sh`.
     Steps 2 and 4 (and 3, if used) have to be finished for this to work.
 6. Run the docker image `studentcodeseparator:student` in the background (detached),
    with mount points `student/logs` to `/logs` and `fifos` to `/fifos`, both as read-write (default).
    TODO move this to Dockerfile / a runner script.
	 Step 5 has to be finished for this to work.
 7. Run the docker image `studentcodeseparator:exercise` in the foreground (not detached),
    with mount points `exercise` to `/data` and `fifos` to `/fifos`, both as read-write (default).
    TODO move this to Dockerfile / a runner script.
	 Step 5 has to be finished for this to work.
 8. Once the exercise container finishes, kill the student container.
    The tests POM file will now have been built, although files created by the build
    (in particular, the contents of `exercise/tests/target`) will not be owned by the current user yet.
	 Step 7 has to be finished for this to work.
 9. Execute `./fix_exercise_ownership.sh`. This will chown build artifacts to the current user.
	 Step 7 has to be finished for this to work.
11. (Optional) Import any build artifacts, like test results.
	 Step 9 has to be finished for this to work.
10. (Optional) To make student log output appear in regular log, execute `cat_student_logfiles.sh`.
	 Step 8 has to be finished for this to work.
12. (Optional) To delete all files from the student submission and tests, execute `clean.sh`.
	 Steps 8 and 9 (and 10, if used) have to be finished for this to work.

## Limitations
- (The student submisison can not create any files outside of its Docker container.
  This is intentional and as designed.)
- Build artifacts created by the tests POM file will only be visible to the outside of the container
  if they are created in `/data` (or subdirectories).
  The POM file will be invoked in `/data/tests` in the Docker container.
  This implies all results from the `target` folder will be visible to the outside.
- The exercise build can't modify or delete any existing files in the `exercise` folder,
  which includes all files in the tests repository.
