import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

const fondo = Color(0xFF101116);
const panel = Color(0xFF1C1E27);
const rojo = Color(0xFFE53935);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OM Cinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: rojo,
          brightness: Brightness.dark,
          surface: panel,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: panel,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: rojo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == null ? const Acceso() : const Catalogo();
        },
      ),
    );
  }
}

class SeccionInfo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const SeccionInfo({
    super.key,
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: rojo, size: 26),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16,
                  )),
                  const SizedBox(height: 5),
                  Text(texto, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Acceso extends StatefulWidget {
  const Acceso({super.key});

  @override
  State<Acceso> createState() => _AccesoState();
}

class _AccesoState extends State<Acceso> {
  final correo = TextEditingController();
  final clave = TextEditingController();
  bool registro = false;
  bool cargando = false;

  Future<void> ingresar() async {
    if (correo.text.trim().isEmpty || clave.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el correo y la contraseña.')),
      );
      return;
    }
    setState(() => cargando = true);
    try {
      if (registro) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correo.text.trim(),
          password: clave.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: correo.text.trim(),
          password: clave.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible acceder: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    correo.dispose();
    clave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OM CINEMA',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(22),
            children: [
              const Icon(Icons.local_movies_rounded, size: 74, color: rojo),
              const SizedBox(height: 14),
              const Text('Tu espacio de cine', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Bienvenido a OM Cinema. Explora nuestro catálogo, conoce los detalles de cada película y comparte tus favoritas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(registro ? 'Crear una cuenta' : 'Iniciar sesión',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 7),
                      Text(registro
                        ? 'Regístrate con tu correo y una contraseña de al menos 6 caracteres.'
                        : 'Ingresa con tu cuenta para consultar el catálogo.',
                        style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: correo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clave,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: cargando ? null : ingresar,
                        child: Text(cargando ? 'Espera un momento...' :
                          registro ? 'Crear cuenta' : 'Entrar al catálogo'),
                      ),
                      TextButton(
                        onPressed: cargando ? null : () => setState(() => registro = !registro),
                        child: Text(registro
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿Eres nuevo? Regístrate aquí'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const SeccionInfo(
                icono: Icons.help_outline,
                titulo: '¿Cómo utilizar OM Cinema?',
                texto: '1. Regístrate o inicia sesión. 2. Explora las películas. 3. Selecciona una para ver su ficha. 4. Usa el menú superior para administrar el catálogo.',
              ),
              const SizedBox(height: 14),
              const Text('Proyecto académico · Catálogo de películas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final peliculas = FirebaseFirestore.instance.collection('peliculas');
  bool administracion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.local_movies, color: rojo),
          SizedBox(width: 10),
          Text('OM CINEMA', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menú de navegación',
            onSelected: (valor) async {
              if (valor == 'salir') {
                await FirebaseAuth.instance.signOut();
              } else {
                setState(() => administracion = valor == 'administrar');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'catalogo', child: Text('Ver catálogo')),
              PopupMenuItem(value: 'administrar', child: Text('Administrar películas')),
              PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: administracion
          ? const Administracion()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: peliculas.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('No fue posible consultar Firebase.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF702020), Color(0xFF22232D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.theaters_rounded, size: 38, color: Colors.white),
                              SizedBox(height: 12),
                              Text('Bienvenido a OM Cinema',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Descubre películas, consulta sus datos y encuentra tu próxima historia favorita.',
                                style: TextStyle(color: Colors.white, height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          const Expanded(child: Text('Películas disponibles',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                          Chip(label: Text('${docs.length} películas')),
                        ]),
                        const SizedBox(height: 8),
                        const SeccionInfo(
                          icono: Icons.touch_app_outlined,
                          titulo: 'Explora el catálogo',
                          texto: 'Selecciona cualquier película para ver su año, director, género, sinopsis e imagen. Para agregar o eliminar títulos, abre el menú de los tres puntos de arriba.',
                        ),
                        const SizedBox(height: 14),
                        if (docs.isEmpty)
                          const SeccionInfo(
                            icono: Icons.movie_outlined,
                            titulo: 'Todavía no hay películas',
                            texto: 'Abre el menú superior y selecciona Administrar películas para registrar la primera.',
                          ),
                        ...docs.map((doc) {
                          final p = doc.data();
                          final imagen = (p['imagen'] ?? '').toString();
                          final anio = (p['anio'] ?? 'Año no registrado').toString();
                          final genero = (p['genero'] ?? 'Sin género').toString();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => Detalle(pelicula: p))),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 90,
                                      height: 120,
                                      child: imagen.isEmpty
                                        ? const ColoredBox(
                                            color: Color(0xFF30323D),
                                            child: Icon(Icons.movie, size: 45, color: Colors.white54))
                                        : Image.network(imagen, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image_outlined, size: 40)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text((p['titulo'] ?? 'Sin título').toString(),
                                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('$genero · $anio',
                                        style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 12),
                                      const Text('Ver detalles', style: TextStyle(
                                        color: Color(0xFFFF7773), fontWeight: FontWeight.bold)),
                                    ],
                                  )),
                                  const Icon(Icons.chevron_right, color: Colors.white54),
                                ]),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        const Text('OM Cinema · Proyecto integrador Flutter y Firebase',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Detalle extends StatelessWidget {
  final Map<String, dynamic> pelicula;
  const Detalle({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    final imagen = (pelicula['imagen'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de película')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (imagen.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(imagen, height: 310, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                      const Icon(Icons.movie, size: 110, color: rojo)),
                )
              else
                const Icon(Icons.movie, size: 110, color: rojo),
              const SizedBox(height: 20),
              Text((pelicula['titulo'] ?? 'Sin título').toString(),
                style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Card(child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información de la película',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Año de estreno: ${pelicula['anio'] ?? 'No registrado'}'),
                    const SizedBox(height: 6),
                    Text('Director: ${pelicula['director'] ?? 'No registrado'}'),
                    const SizedBox(height: 6),
                    Text('Género: ${pelicula['genero'] ?? 'No registrado'}'),
                  ],
                ),
              )),
              const SizedBox(height: 14),
              Card(child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sinopsis', style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text((pelicula['sinopsis'] ?? 'Sin sinopsis registrada.').toString(),
                      style: const TextStyle(height: 1.6, color: Colors.white70)),
                  ],
                ),
              )),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al catálogo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Administracion extends StatefulWidget {
  const Administracion({super.key});
  @override
  State<Administracion> createState() => _AdministracionState();
}

class _AdministracionState extends State<Administracion> {
  final titulo = TextEditingController();
  final anio = TextEditingController();
  final director = TextEditingController();
  final genero = TextEditingController();
  final sinopsis = TextEditingController();
  final imagen = TextEditingController();
  final peliculas = FirebaseFirestore.instance.collection('peliculas');
  bool guardando = false;

  Future<void> guardar() async {
    if ([titulo, anio, director, genero, sinopsis, imagen]
        .any((controlador) => controlador.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')));
      return;
    }
    final url = Uri.tryParse(imagen.text.trim());
    final anioNumero = int.tryParse(anio.text.trim());
    if (anioNumero == null || anioNumero < 1888 ||
        anioNumero > DateTime.now().year + 5 ||
        url == null || !url.hasAuthority ||
        (url.scheme != 'https' && url.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa el año y la URL de imagen.')));
      return;
    }
    setState(() => guardando = true);
    try {
      // Petición HTTP para comprobar que la imagen responde.
      final respuesta = await http.get(url).timeout(const Duration(seconds: 10));
      if (respuesta.statusCode != 200) {
        throw Exception('La URL de imagen no respondió correctamente.');
      }
      await peliculas.add({
        'titulo': titulo.text.trim(),
        'anio': anioNumero,
        'director': director.text.trim(),
        'genero': genero.text.trim(),
        'sinopsis': sinopsis.text.trim(),
        'imagen': imagen.text.trim(),
        'creadoEn': FieldValue.serverTimestamp(),
      });
      titulo.clear();
      anio.clear();
      director.clear();
      genero.clear();
      sinopsis.clear();
      imagen.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película guardada en Firebase.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    anio.dispose();
    director.dispose();
    genero.dispose();
    sinopsis.dispose();
    imagen.dispose();
    super.dispose();
  }

  Widget campo(String etiqueta, TextEditingController controlador,
      {int lineas = 1, IconData icono = Icons.edit_outlined}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        maxLines: lineas,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('Administración del catálogo',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Registra nuevas películas o elimina las que ya no quieras mostrar.',
              style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            const SeccionInfo(
              icono: Icons.info_outline,
              titulo: 'Instrucciones para agregar una película',
              texto: 'Completa los seis campos y pega una URL pública de imagen (http o https). Después selecciona Agregar película. El registro se guardará en Firebase y aparecerá en el catálogo.',
            ),
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Nueva película', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  campo('Título', titulo, icono: Icons.movie_outlined),
                  campo('Año de estreno', anio, icono: Icons.calendar_today_outlined),
                  campo('Director', director, icono: Icons.person_outline),
                  campo('Género', genero, icono: Icons.category_outlined),
                  campo('Sinopsis', sinopsis, lineas: 3, icono: Icons.description_outlined),
                  campo('URL de imagen', imagen, icono: Icons.image_outlined),
                  const SizedBox(height: 6),
                  FilledButton.icon(
                    onPressed: guardando ? null : guardar,
                    icon: const Icon(Icons.add),
                    label: Text(guardando ? 'Guardando...' : 'Agregar película'),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 22),
            const Text('Películas registradas', style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Para eliminar una película, presiona el ícono de basura junto a su nombre.',
              style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: peliculas.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('No fue posible consultar las películas.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Text('No hay películas registradas.');
                }
                return Column(children: snapshot.data!.docs.map((doc) {
                  final p = doc.data();
                  return Card(child: ListTile(
                    leading: const Icon(Icons.movie_outlined, color: rojo),
                    title: Text((p['titulo'] ?? 'Sin título').toString()),
                    subtitle: Text((p['genero'] ?? 'Sin género').toString()),
                    trailing: IconButton(
                      tooltip: 'Eliminar película',
                      icon: const Icon(Icons.delete_outline, color: rojo),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dialogo) => AlertDialog(
                            title: const Text('Eliminar película'),
                            content: Text('¿Quieres eliminar "${p['titulo'] ?? 'esta película'}" del catálogo?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogo, false),
                                child: const Text('Cancelar')),
                              FilledButton(onPressed: () => Navigator.pop(dialogo, true),
                                child: const Text('Eliminar')),
                            ],
                          ),
                        );
                        if (confirmar != true) return;
                        try {
                          await doc.reference.delete();
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar: $e')));
                        }
                      },
                    ),
                  ));
                }).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
