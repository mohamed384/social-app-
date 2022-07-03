import 'package:flutter/material.dart';
import 'package:ryze/screens/comment/cubit.dart';

String setLanguageCode(String language) {
  switch (language) {
    case 'en':
      return 'English';
    case 'fr':
      return 'French';
    case 'ar':
      return 'Arabic';
    case 'it':
      return 'Italian';
    case 'ru':
      return 'Russian';
    case 'es':
      return 'Spanish';
    case 'de':
      return 'German';
    default:
      return 'English';
  }
}

class TitleWidget extends StatelessWidget {
  final CommentCubit cubit;
  final ValueChanged<String?> onChangedLanguage1;
  final ValueChanged<String?> onChangedLanguage2;

  const TitleWidget({
    required this.onChangedLanguage1,
    required this.onChangedLanguage2,
    Key? key,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            setLanguageCode(cubit.from),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.translate, color: Colors.white),
          const SizedBox(width: 12),
          DropDownWidget(
            value: cubit.language2,
            onChangedLanguage: onChangedLanguage2,
          ),
        ],
      );
}

class DropDownWidget extends StatelessWidget {
  final String value;
  final void Function(String?)? onChangedLanguage;
  static final languages = <String>[
    'English',
    'Spanish',
    'Arabic',
    'French',
    'German',
    'Italian',
    'Russian'
  ];

  const DropDownWidget({
    required this.value,
    required this.onChangedLanguage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = languages
        .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
        .toList();

    return DropdownButton<String>(
      value: value,
      dropdownColor: Colors.grey.withOpacity(0.9),
      icon: const Icon(Icons.expand_more, color: Colors.grey),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      onChanged: onChangedLanguage,
      items: items,
    );
  }
}
