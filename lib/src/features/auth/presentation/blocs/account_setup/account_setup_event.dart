part of 'account_setup_bloc.dart';

@freezed
class AccountSetupEvent with _$AccountSetupEvent {
  const factory AccountSetupEvent.pageChanged(int index) =
      EventAccountSetupPageChanged;
}
