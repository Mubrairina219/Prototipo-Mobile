import 'package:flutter/material.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Política de Privacidad',
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: const Text(
'''
TÉRMINOS DE USO

1. Aceptación de los Términos
Al registrar una cuenta y utilizar la aplicación (en adelante, "la App"), el usuario acepta los presentes Términos de Uso y nuestra Política de Privacidad. Si no está de acuerdo, no debe utilizar la plataforma.

2. Registro y Seguridad de la Cuenta
Para acceder a las funciones completas de la App, el usuario debe registrar una cuenta utilizando datos veraces, exactos y vigentes.

El usuario es responsable de mantener la confidencialidad de su contraseña y de todas las actividades que ocurran bajo su cuenta.

La empresa se reserva el derecho de rechazar el registro o cancelar cuentas si se detecta uso fraudulento o violación de estos términos.

3. Uso Aceptable del Servicio
La App está diseñada para uso personal e informativo. El usuario se compromete a no utilizarla para fines ilícitos, dañar el sistema, ni intentar acceder de forma no autorizada a los servidores.

El usuario reconoce que la información de horarios, rutas y tiempos de espera se basa en datos proporcionados por terceros y operadores de transporte, pudiendo existir variaciones por el tráfico o imprevistos.

4. Modificación de los Términos
La empresa se reserva el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor tras su publicación en la App. El uso continuado tras dichas modificaciones constituirá la aceptación de los nuevos términos.

POLÍTICA DE PRIVACIDAD

1. Información que Recopilamos

Datos de Registro:
• Nombre
• Dirección de correo electrónico
• Número de teléfono
• Contraseña

Datos de Ubicación:
La App recopila datos de ubicación GPS para calcular rutas y mostrar paradas cercanas, únicamente cuando el usuario lo autorice.

2. Finalidad del Tratamiento de Datos

La información recopilada será utilizada para:

• Operar y mejorar la funcionalidad de la aplicación.
• Mostrar líneas de transporte público cercanas.
• Mostrar paradas próximas.
• Calcular tiempos estimados de llegada.
• Enviar notificaciones importantes relacionadas con el servicio.

3. Compartir Información

Tus datos personales o de ubicación no serán vendidos, alquilados ni compartidos con terceros con fines comerciales o publicitarios.

Únicamente podrán ser compartidos con proveedores tecnológicos que garanticen medidas adecuadas de seguridad o cuando exista obligación legal.

4. Derechos del Usuario

El usuario tiene derecho a:

• Acceder a sus datos.
• Rectificar información incorrecta.
• Solicitar la eliminación de su cuenta.
• Revocar permisos de ubicación desde la configuración del dispositivo.

5. Medidas de Seguridad

Implementamos medidas técnicas y organizativas para proteger la información frente a accesos no autorizados, pérdida, alteración o divulgación indebida.
''',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}