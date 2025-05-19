import 'dart:developer';
import 'dart:io';
import 'package:chatbot_dcco/views/profile/widgets/build_display_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_dcco/views/chat/widgets/boxes.dart';
import 'package:chatbot_dcco/models/settings.dart';
import 'package:chatbot_dcco/controllers/settings_controller.dart';
import 'package:chatbot_dcco/views/profile/widgets/settings_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userImage = '';
  String userName = 'DCCO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // actions: [
        //   IconButton(
        //     // icon: const Icon(Icons.check),
        //     icon: const Icon(CupertinoIcons.checkmark),
        //     onPressed: () {
        //       // save data
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: const BuildDisplayImage(
                  imagePath: 'assets/images/DCCO.png', // Ruta de tu imagen PNG
                ),
              ),

              const SizedBox(height: 20.0),

              // user name
              Text(
                userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 20.0),

              // Generic description of the chatbot
              const Text(
                'El chatbot está diseñado para asistir a estudiantes y personas interesadas en las carreras de Software, ITIN e ITIN en línea. Proporciona soporte respondiendo preguntas frecuentes, ofreciendo orientación y ayudando a los usuarios a navegar por los recursos del departamento de manera efectiva.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),

              const SizedBox(height: 40.0),

              ValueListenableBuilder<Box<Settings>>(
                valueListenable: Boxes.getSettings().listenable(),
                builder: (context, box, child) {
                  if (box.isEmpty) {
                    return Column(
                      children: [
                        // Theme
                        SettingsTile(
                          // icon: Icons.light_mode,
                          icon: CupertinoIcons.sun_max,
                          title: 'Theme',
                          value: false,
                          onChanged: (value) {
                            final settingProvider =
                            context.read<SettingsProvider>();
                            settingProvider.toggleDarkMode(
                              value: value,
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    final settings = box.getAt(0);
                    return Column(
                      children: [
                        // theme
                        SettingsTile(
                          icon: settings!.isDarkTheme
                              ? CupertinoIcons.moon_fill
                              : CupertinoIcons.sun_max_fill,
                          title: 'Tema',
                          value: settings.isDarkTheme,
                          onChanged: (value) {
                            final settingProvider =
                            context.read<SettingsProvider>();
                            settingProvider.toggleDarkMode(
                              value: value,
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
