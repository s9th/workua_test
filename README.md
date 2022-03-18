# workua_test - A simple test task for a job interview

## Getting Started

Application is written using Flutter v. 2.10.3.

Libraries used:

- flutter_riverpod for state management and dependency injection
- shimmer_animation for loading animation of an individual GIF
- dio as the http client
- cached_network_image for convenience
- freezed for generating boilerplate code for immutable classes
- mockito for mocking dependencies in unit tests
- build_runner for running code generation scripts
- very_good_analysis for static code analysis

To run the project after cloning the repository run the following commands in terminal (provided flutter is already installed):

- futter pub get
- flutter pub run build_runner build
- flutter run
