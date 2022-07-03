abstract class AuthStates {}

class SocialLoginInitialState extends AuthStates {}

class SocialLoginLoadingState extends AuthStates {}

class SocialLoginSuccessState extends AuthStates {}

class SocialLoginErrorState extends AuthStates {
  final String error;

  SocialLoginErrorState(this.error);
}

class SocialChangePasswordVisibilityState extends AuthStates {}

class SocialChangeSignSectionState extends AuthStates {}

//for Signup States
class SocialRegisterInitialState extends AuthStates {}

class SocialRegisterLoadingState extends AuthStates {}

class SocialRegisterSuccessState extends AuthStates {}

class SocialRegisterErrorState extends AuthStates {
  final String error;

  SocialRegisterErrorState(this.error);
}

class SocialCreateUserSuccessState extends AuthStates {}

class SocialCreateUserErrorState extends AuthStates {
  final String error;

  SocialCreateUserErrorState(this.error);
}

class SocialRegisterChangePasswordVisibilityState extends AuthStates {}

class SocialChangeImagesPath extends AuthStates {}

class TextFieldPostState extends AuthStates {}

class CurrentIndicatorIndexAuthState extends AuthStates {}

class UploadToFirebaseSuccessState extends AuthStates {}

class UploadToFirebaseFailedState extends AuthStates {}

class CreatePostSuccessState extends AuthStates {}

class CreatePostFailedState extends AuthStates {}

class CreateStorySuccessState extends AuthStates {}

class CreateStoryFailedState extends AuthStates {}

class UpdatePostSuccessState extends AuthStates {}

class UpdatePostFailedState extends AuthStates {}

class DeletePostImageSuccessState extends AuthStates {}

class DeletePostImageFailedState extends AuthStates {}

class GetUrlFailedState extends AuthStates {}

class IsUploadedPostState extends AuthStates {}

class RemoveOneImagesPathState extends AuthStates {}

class ChangeTextFieldSearch extends AuthStates {}

class ChangeTabSearchIndexState extends AuthStates {}
