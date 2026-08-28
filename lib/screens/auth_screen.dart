import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/registration_api.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pulse_ring.dart';

/// Multi-step account creation, wired to the real POST /registration/*
/// endpoints: phone+PIN -> BVN -> NIN -> proof of address -> face -> the
/// existing (mocked, no server counterpart) voiceprint capture -> done.
/// Each KYC step is real and moves the account up Nigeria's CBN-style
/// tiers (see app/registration/interfaces.py): BVN alone reaches Tier 1,
/// BVN+NIN reaches Tier 2, +address reaches Tier 3. BVN/NIN/address/face
/// verification themselves are mocked — no real licensed KYC provider —
/// same posture as the rest of this backend.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _bvnController = TextEditingController();
  final _ninController = TextEditingController();

  String _selectedCountryCode = '+234';
  String _otp = '';
  final _otpController = TextEditingController();
  String _countryOfResidence = 'Nigeria';

  final _emailController = TextEditingController();
  String _emailOtp = '';
  final _emailOtpController = TextEditingController();
  final _passwordController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otherNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _pinSetupController = TextEditingController();
  String _gender = 'Prefer not to say';

  final _addressSearchController = TextEditingController();
  String _addressSearchQuery = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _bvnController.dispose();
    _ninController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _emailOtpController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _otherNameController.dispose();
    _dobController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _addressSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final appState = widget.appState;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => appState.go(AppScreen.welcome),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 4),
                _stepBody(appState),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stepBody(AppState appState) {
    switch (appState.regStep) {
      case 0:
        return _phoneStep(appState);
      case 1:
        return _otpStep(appState);
      case 2:
        return _countryStep(appState);
      case 3:
        return _countryFeaturesStep(appState);
      case 4:
        return _emailStep(appState);
      case 5:
        return _emailOtpStep(appState);
      case 6:
        return _passwordStep(appState);
      case 7:
        return _personalDetailsStep(appState);
      case 8:
        return _addressSearchStep(appState);
      case 9:
        return _verifyNinStep(appState);
      case 10:
        return _verifyBvnStep(appState);
      case 11:
        return _mockCaptureStep(
          appState: appState,
          title: 'Face verification',
          body: 'Take a quick selfie so we know it\'s really you opening this account.',
          buttonLabel: 'Simulate face captured',
          onSubmit: appState.submitFaceStep,
        );
      case 12:
        return _mockCaptureStep(
          appState: appState,
          title: 'Voiceprint',
          body: 'Repeat the phrase on screen to secure your account with voice recognition.',
          buttonLabel: 'Simulate voiceprint enrolled',
          onSubmit: appState.submitVoiceStep,
        );
      case 13:
        return _pinSetupStep(appState);
      case 14:
        return _onboardingCompletedStep(appState);
      default:
        return _voiceprintStep(appState);
    }
  }

  Widget _phoneStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set up your account', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 26),
        _label('PHONE NUMBER'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _selectedCountryCode,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: WaziColors.textAt(.6)),
                style: WaziText.grotesk(size: 15, weight: FontWeight.w500, color: WaziColors.textAt(.6)),
                dropdownColor: WaziColors.card,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCountryCode = newValue;
                    });
                  }
                },
                items: <String>['+234', '+254', '+27', '+44', '+1']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: WaziColors.textAt(.14)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                  style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '802 431 9902',
                    hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _phoneController.text.trim().isNotEmpty
                ? () async {
                    await appState.submitPhoneStep(_selectedCountryCode + _phoneController.text.trim());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _otpStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone number verification', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent a code to $_selectedCountryCode ${_phoneController.text.trim()}. (Mocked: any 4 digits will work)',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('VERIFICATION CODE'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (val) {
              setState(() {
                _otp = val;
              });
            },
            style: WaziText.grotesk(size: 24, weight: FontWeight.w500, letterSpacing: 8.0),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: '0000',
              hintStyle: WaziText.grotesk(size: 24, weight: FontWeight.w500, letterSpacing: 8.0, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _otp.length == 4
                ? () async {
                    await appState.submitPhoneOtpStep(_selectedCountryCode + _phoneController.text.trim(), _otp);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Verify', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _countryStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your country', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Where do you live most of the time?',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('COUNTRY'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _countryOfResidence,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: WaziColors.textAt(.6)),
              style: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.8)),
              dropdownColor: WaziColors.card,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _countryOfResidence = newValue;
                  });
                }
              },
              items: <String>['Nigeria', 'Kenya', 'South Africa', 'United Kingdom', 'United States']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await appState.submitCountryStep(_selectedCountryCode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _countryFeaturesStep(AppState appState) {
    final features = _countryOfResidence == 'Nigeria'
        ? ['Send and receive NGN instantly', 'Pay bills and buy airtime', 'Voice-activated transfers', 'Earn interest on your balance']
        : ['Hold balances in multiple currencies', 'Send money globally with low fees', 'Voice-activated transfers', 'Virtual and physical cards'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What you can do in $_countryOfResidence', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Here is what Wazi unlocks for you.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 32),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: WaziColors.tealAt(.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 18, color: WaziColors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(feature, style: WaziText.grotesk(size: 17, weight: FontWeight.w500)),
              ),
            ],
          ),
        )),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              appState.regStep = 4;
              appState.notifyListeners();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _emailStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is your email?', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'We use this to send you receipts and important updates.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('EMAIL ADDRESS'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'name@example.com',
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _emailController.text.trim().isNotEmpty && _emailController.text.contains('@')
                ? () async {
                    await appState.submitEmailStep(_emailController.text.trim());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              appState.regStep = 6;
              appState.notifyListeners();
            },
            child: Text('Skip', style: WaziText.inter(size: 15, color: WaziColors.textAt(.6))),
          ),
        ),
      ],
    );
  }

  Widget _emailOtpStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your email', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent a code to ${_emailController.text.trim()}. (Mocked: any 4 digits will work)',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('VERIFICATION CODE'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _emailOtpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (val) {
              setState(() {
                _emailOtp = val;
              });
            },
            style: WaziText.grotesk(size: 24, weight: FontWeight.w500, letterSpacing: 8.0),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: '0000',
              hintStyle: WaziText.grotesk(size: 24, weight: FontWeight.w500, letterSpacing: 8.0, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _emailOtp.length == 4
                ? () async {
                    await appState.submitEmailOtpStep(_emailController.text.trim(), _emailOtp);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Verify', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _passwordStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create your password', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'This will be used to approve payments and log in. Must be at least 9 characters, include an uppercase letter, a lowercase letter, and a special character.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('PASSWORD'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (_) => setState(() {}),
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter password',
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isPasswordValid(_passwordController.text) && !appState.busy
                ? () async => await appState.submitPasswordStep(_passwordController.text)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Create account', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _personalDetailsStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell us about yourself', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Please ensure these details exactly match your legal ID.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        
        const SizedBox(height: 32),
        Text('Personal Information', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, color: WaziColors.gold)),
        const SizedBox(height: 16),
        
        _buildField('LEGAL FIRST NAME', _firstNameController),
        _buildField('LAST NAME', _lastNameController),
        _buildField('OTHER NAME (OPTIONAL)', _otherNameController),
        _buildField('DATE OF BIRTH', _dobController, hint: 'DD/MM/YYYY', keyboardType: TextInputType.datetime),
        
        _label('GENDER'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: WaziColors.textAt(.6)),
              style: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.8)),
              dropdownColor: WaziColors.card,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _gender = newValue;
                  });
                }
              },
              items: <String>['Prefer not to say', 'Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 42),
        Text('Residential Address', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, color: WaziColors.gold)),
        const SizedBox(height: 16),
        
        _label('COUNTRY OF RESIDENCE'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: Text(_countryOfResidence, style: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.5))),
        ),
        const SizedBox(height: 20),
        
        _buildField('STATE / PROVINCE', _stateController),
        _buildField('CITY', _cityController),
        _buildField('STREET ADDRESS', _addressController),
        _buildField('ZIP / POSTAL CODE', _zipCodeController),
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await appState.submitPersonalDetailsStep(
                _firstNameController.text.trim(),
                _lastNameController.text.trim(),
                _otherNameController.text.trim(),
                _dobController.text.trim(),
                _gender
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Continue', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _addressSearchStep(AppState appState) {
    final mockedResults = _addressSearchQuery.isEmpty
        ? <String>[]
        : [
            '${_addressSearchQuery}123 Main St, Springfield',
            '${_addressSearchQuery}456 Elm St, Springfield',
            '${_addressSearchQuery}789 Oak Ave, Springfield'
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm your address', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Search for your residential address so we can verify it.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 26),
        _label('ADDRESS SEARCH'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: Row(
            children: [
              Icon(Icons.search, color: WaziColors.textAt(.4)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _addressSearchController,
                  onChanged: (val) {
                    setState(() {
                      _addressSearchQuery = val;
                    });
                  },
                  style: WaziText.grotesk(size: 17, weight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start typing your address...',
                    hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mockedResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: mockedResults.map((res) {
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: WaziColors.gold),
                    title: Text(res, style: WaziText.grotesk(size: 16, weight: FontWeight.w500)),
                    onTap: () {
                      setState(() {
                        _addressSearchController.text = res;
                        _addressSearchQuery = ''; // hide results
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        if (appState.error != null) ...[
          const SizedBox(height: 12),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addressSearchController.text.isNotEmpty && !appState.busy
                ? appState.submitAddressStep
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Confirm address', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  bool _isPasswordValid(String pwd) {
    if (pwd.length < 9) return false;
    if (!pwd.contains(RegExp(r'[a-z]'))) return false;
    if (!pwd.contains(RegExp(r'[A-Z]'))) return false;
    if (!pwd.contains(RegExp(r'[^a-zA-Z0-9]'))) return false;
    return true;
  }

  Widget _verifyNinStep(AppState appState) {
    final ninVerified = appState.regStatus?.ninVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your identity', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Provide your NIN to secure your account. You can skip this and use your BVN instead.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 32),
        
        _label('NATIONAL IDENTITY NUMBER (NIN)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _ninController,
            enabled: !ninVerified,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '11 digits',
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        
        if (appState.error != null) ...[
          const SizedBox(height: 20),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _ninController.text.trim().isNotEmpty && !appState.busy
                ? () async {
                    if (ninVerified) {
                      appState.skipRegStep();
                    } else {
                      final success = await appState.submitNinStep(_ninController.text.trim());
                      if (success) {
                        appState.skipRegStep();
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: WaziColors.card,
              disabledForegroundColor: WaziColors.textAt(.3),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text(ninVerified ? 'Continue' : 'Verify NIN', style: WaziText.grotesk(size: 16, weight: FontWeight.w600)),
          ),
        ),
        
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => appState.skipRegStep(),
            child: Text(
              'Use BVN instead',
              style: WaziText.inter(size: 14, color: WaziColors.textAt(.6), weight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _verifyBvnStep(AppState appState) {
    final bvnVerified = appState.regStatus?.bvnVerified ?? false;
    final ninVerified = appState.regStatus?.ninVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your BVN', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Provide your Bank Verification Number (BVN).',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 32),
        
        _label('BANK VERIFICATION NUMBER (BVN)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _bvnController,
            enabled: !bvnVerified,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '11 digits',
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        
        if (appState.error != null) ...[
          const SizedBox(height: 20),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _bvnController.text.trim().isNotEmpty && !appState.busy
                ? () async {
                    if (bvnVerified) {
                      appState.completeIdentityVerification();
                    } else {
                      final success = await appState.submitBvnStep(_bvnController.text.trim());
                      if (success) {
                        appState.completeIdentityVerification();
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: WaziColors.card,
              disabledForegroundColor: WaziColors.textAt(.3),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text(bvnVerified ? 'Continue' : 'Verify BVN', style: WaziText.grotesk(size: 16, weight: FontWeight.w600)),
          ),
        ),
        
        if (ninVerified) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => appState.completeIdentityVerification(),
              child: Text(
                'Skip this step',
                style: WaziText.inter(size: 14, color: WaziColors.textAt(.6), weight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _kycTextStep({
    required AppState appState,
    required String title,
    required String label,
    required String hint,
    required TextEditingController controller,
    required Future<bool> Function() onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text(
          'Mocked verification for this build — no real BVN/NIN lookup happens. Any 11 digits pass except 00000000000.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 22),
        _label(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 11,
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(border: InputBorder.none, counterText: '', hintText: hint, hintStyle: WaziText.inter(size: 15, color: WaziColors.textAt(.3))),
          ),
        ),
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!appState.busy && controller.text.trim().length == 11) ? () => onSubmit() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Verify', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: appState.busy ? null : appState.skipRegStep,
            child: Text('Skip for now', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
          ),
        ),
      ],
    );
  }

  Widget _mockCaptureStep({
    required AppState appState,
    required String title,
    required String body,
    required String buttonLabel,
    required Future<bool> Function() onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text(body, style: WaziText.inter(size: 14, color: WaziColors.textAt(.6), height: 1.4)),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: WaziColors.card,
            border: Border.all(color: WaziColors.textAt(.1), style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.camera_alt_outlined, size: 34, color: WaziColors.textAt(.3)),
        ),
        if (appState.error != null) ...[
          const SizedBox(height: 10),
          Text(appState.error!, style: WaziText.inter(size: 13, color: WaziColors.gold)),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: appState.busy ? null : () => onSubmit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text(buttonLabel, style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: appState.busy ? null : appState.skipRegStep,
            child: Text('Skip for now', style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5))),
          ),
        ),
      ],
    );
  }

  Widget _voiceprintStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last step', style: WaziText.grotesk(size: 26, weight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        _VoiceprintCard(appState: appState),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => appState.finishRegistration(),
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Finish setup', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.bg)),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: WaziText.inter(size: 12, color: WaziColors.textAt(.45), letterSpacing: 1.2));

  Widget _pinSetupStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set your PIN', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Create a 4-digit PIN for quick access to your account and to confirm transactions.',
          style: WaziText.inter(size: 13, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 32),
        _label('ENTER PIN'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(color: WaziColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: WaziColors.textAt(.09))),
          child: TextField(
            controller: _pinSetupController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            onChanged: (_) => setState(() {}),
            style: WaziText.grotesk(size: 17, weight: FontWeight.w500),
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: '4 digits',
              hintStyle: WaziText.grotesk(size: 17, weight: FontWeight.w500, color: WaziColors.textAt(.3)),
            ),
          ),
        ),
        const SizedBox(height: 42),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pinSetupController.text.length == 4 && !appState.busy
                ? () => appState.submitPinSetup(_pinSetupController.text)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: WaziColors.card,
              disabledForegroundColor: WaziColors.textAt(.3),
            ),
            child: Text('Set PIN', style: WaziText.grotesk(size: 16, weight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _onboardingCompletedStep(AppState appState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline, color: WaziColors.teal, size: 80),
        const SizedBox(height: 24),
        Text('All set!', style: WaziText.grotesk(size: 30, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Your account is ready and fully secured.',
          textAlign: TextAlign.center,
          style: WaziText.inter(size: 14, color: WaziColors.textAt(.5), height: 1.4),
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: appState.busy ? null : appState.finishRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: WaziColors.gold,
              foregroundColor: WaziColors.bg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: appState.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WaziColors.bg))
                : Text('Go to Home', style: WaziText.grotesk(size: 16, weight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.status});

  final RegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    final limits = status.limits;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: WaziColors.tealAt(.1),
        border: Border.all(color: WaziColors.tealAt(.3)),
      ),
      child: Row(
        children: [
          Text('TIER ${status.tier}', style: WaziText.grotesk(size: 12, weight: FontWeight.w700, color: WaziColors.teal, letterSpacing: 1.2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Daily limit ${limits.dailyLimitFormatted}${limits.maxBalanceFormatted != null ? ' · Balance up to ${limits.maxBalanceFormatted}' : ''}',
              style: WaziText.inter(size: 12, color: WaziColors.textAt(.6)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKeypad extends StatelessWidget {
  const _MiniKeypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: _keys.map((k) {
        return GestureDetector(
          onTap: k.isEmpty ? null : () => onKey(k),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: k.isEmpty ? Colors.transparent : WaziColors.textAt(.06)),
            alignment: Alignment.center,
            child: Text(k, style: WaziText.grotesk(size: 18, weight: FontWeight.w500)),
          ),
        );
      }).toList(),
    );
  }
}

class _VoiceprintCard extends StatelessWidget {
  const _VoiceprintCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final status = appState.enrolled
        ? 'Voiceprint saved — 2 of 2 recorded'
        : (appState.enrolling ? 'Listening… keep talking' : 'Tap to record · about 4 seconds');
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [WaziColors.tealAt(.13), WaziColors.tealAt(.03)]),
        border: Border.all(color: WaziColors.tealAt(.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VOICEPRINT', style: WaziText.grotesk(size: 12, weight: FontWeight.w600, color: WaziColors.teal, letterSpacing: 1.7)),
              Text('Step 2 of 2', style: WaziText.inter(size: 11, color: WaziColors.tealAt(.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text('Record your phrase', style: WaziText.grotesk(size: 21, weight: FontWeight.w600, letterSpacing: -0.2)),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.6), height: 1.4),
              children: [
                const TextSpan(text: 'Say '),
                TextSpan(text: '"My voice is my key at Wazi"', style: TextStyle(color: WaziColors.text)),
                const TextSpan(text: ' twice. This tells us it\'s you — your PIN still approves every payment.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: appState.startEnroll,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (appState.enrolling)
                        PulseRing(color: WaziColors.teal, size: 60, duration: const Duration(milliseconds: 1600), maxScale: 1.35, startOpacity: 1.0),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: WaziColors.teal),
                        alignment: Alignment.center,
                        child: Container(width: 12, height: 22, decoration: BoxDecoration(color: WaziColors.bg, borderRadius: BorderRadius.circular(7))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(18, (i) {
                      final h = appState.enrolling
                          ? 8 + (26 * (math.sin(i * 1.1)).abs()).round()
                          : (appState.enrolled ? 6 + (20 * (math.sin(i * 0.8)).abs()).round() : 4);
                      return Expanded(
                        child: Container(
                          height: h.toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: appState.enrolling ? WaziColors.teal : WaziColors.tealAt(.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(status, style: WaziText.inter(size: 12.5, color: WaziColors.teal)),
        ],
      ),
    );
  }
}
