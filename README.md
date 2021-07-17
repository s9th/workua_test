# workua_test

## Getting Started

Application is written using Flutter v. 2.3.0-24.1.pre (beta channel of flutter).

Libraries used:

- flutter_riverpod for state management and dependency injection
- shimmer_animation for loading animation of an individual GIF
- dio as the http client
- freezed for generating boilerplate code for immutable classes
- build_runner for running code generation scripts
- very_good_analysis for static code analysis

To run the project after cloning the repository run the following commands in terminal (provided flutter is already installed):

- flutter channel beta
- futter pub get
- flutter pub run build_runner build
- flutter run
