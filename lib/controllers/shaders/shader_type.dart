enum ShaderType {
  /// шейдер тумана
  fog('shaders/fog.frag'),

  /// шейдер сгорания карты
  burn('shaders/burn.frag');

  final String path;
  const ShaderType(this.path);
}
