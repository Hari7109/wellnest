import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_outlined_button.dart';
import '../../widgets/custom_text_form_field.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key})
      : super(
    key: key,
  );

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(
                left: 16.h,
                top: 68.v,
                right: 16.h,
              ),
              child: Column(
                children: [
                  CustomIconButton(
                    height: 72.adaptSize,
                    width: 72.adaptSize,
                    padding: EdgeInsets.all(20.h),
                    decoration: IconButtonStyleHelper.fillPrimary,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgClose,
                    ),
                  ),
                  SizedBox(height: 16.v),
                  Text(
                    "Welcome to E-com",
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 10.v),
                  Text(
                    "Sign in to continue",
                    style: CustomTextStyles.bodySmall12,
                  ),
                  SizedBox(height: 28.v),
                  _buildEmail(context),
                  SizedBox(height: 10.v),
                  _buildPassword(context),
                  SizedBox(height: 18.v),
                  _buildSignIn(context),
                  SizedBox(height: 16.v),
                  _buildOrline(context),
                  SizedBox(height: 16.v),
                  _buildLoginWith(context),
                  SizedBox(height: 8.v),
                  _buildLoginWith1(context),
                  SizedBox(height: 17.v),
                  Text(
                    "Forgot Password?",
                    style: theme.textTheme.labelLarge,
                  ),
                  SizedBox(height: 7.v),
                  GestureDetector(
                    onTap: () {
                      onTapTxtDonthaveanaccount(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Don’t have an account?",
                            style: CustomTextStyles.bodySmall12_1,
                          ),
                          TextSpan(
                            text: " ",
                          ),
                          TextSpan(
                            text: "Register",
                            style: theme.textTheme.labelLarge,
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 5.v)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildEmail(BuildContext context) {
    return CustomTextFormField(
      controller: emailController,
      hintText: "Your Email",
      textInputType: TextInputType.emailAddress,
      prefix: Container(
        margin: EdgeInsets.fromLTRB(16.h, 12.v, 10.h, 12.v),
        child: CustomImageView(
          imagePath: ImageConstant.imgEmailIcon,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
      prefixConstraints: BoxConstraints(
        maxHeight: 48.v,
      ),
    );
  }

  /// Section Widget
  Widget _buildPassword(BuildContext context) {
    return CustomTextFormField(
      controller: passwordController,
      hintText: "Password",
      textInputAction: TextInputAction.done,
      textInputType: TextInputType.visiblePassword,
      prefix: Container(
        margin: EdgeInsets.fromLTRB(16.h, 12.v, 10.h, 12.v),
        child: CustomImageView(
          imagePath: ImageConstant.imgLocation,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
      prefixConstraints: BoxConstraints(
        maxHeight: 48.v,
      ),
      obscureText: true,
    );
  }

  /// Section Widget
  Widget _buildSignIn(BuildContext context) {
    return CustomElevatedButton(
      text: "Sign In",
    );
  }

  /// Section Widget
  Widget _buildOrline(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.v,
            bottom: 9.v,
          ),
          child: SizedBox(
            width: 134.h,
            child: Divider(),
          ),
        ),
        Text(
          "OR",
          style: CustomTextStyles.titleSmallBluegray300_1,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10.v,
            bottom: 9.v,
          ),
          child: SizedBox(
            width: 137.h,
            child: Divider(),
          ),
        )
      ],
    );
  }

  /// Section Widget
  Widget _buildLoginWith(BuildContext context) {
    return CustomOutlinedButton(
      text: "Login with Google",
      leftIcon: Container(
        margin: EdgeInsets.only(right: 30.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgGoogleIcon,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildLoginWith1(BuildContext context) {
    return CustomOutlinedButton(
      text: "Login with facebook",
      leftIcon: Container(
        margin: EdgeInsets.only(right: 30.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgFacebookIcon,
          height: 24.adaptSize,
          width: 24.adaptSize,
        ),
      ),
    );
  }

  /// Navigates to the registerScreen when the action is triggered.
  onTapTxtDonthaveanaccount(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registerScreen);
  }
}
    