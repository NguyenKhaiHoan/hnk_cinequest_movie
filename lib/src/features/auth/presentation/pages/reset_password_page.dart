import 'package:cinequest/src/core/extensions/string_extension.dart';
import 'package:cinequest/src/features/auth/presentation/blocs/reset_password/reset_password_bloc.dart';
import 'package:cinequest/src/features/auth/presentation/widgets/reset_password/rp_reset_password_view.dart';
import 'package:cinequest/src/features/auth/presentation/widgets/reset_password/rp_verification_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '_mixins/reset_password_page.mixin.dart';

/// Trang ResetPassword
class ResetPasswordPage extends StatelessWidget {
  /// Constructor
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(),
      child: const _Page(),
    );
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with _PageMixin {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        RPResetPasswordView(
          resetPasswordFormKey: _resetPasswordFormKey,
          emailTextEditingController: _emailTextEditingController,
          onSend: _send,
          onEmailChanged: _changeEmail,
        ),
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          builder: (context, state) {
            return RPVerificationLinkView(
              title: 'Check your Inbox'.hardcoded,
              subtitle:
                  'We have sent a link to ${state.email} with instructions to reset your password',
              email: state.email,
              onBack: _back,
              onResend: _resend,
            );
          },
        ),
      ],
    );
  }
}
