import esbuild from 'esbuild';

await esbuild.build({
  entryPoints: ['src/wallet.js'],
  bundle: true,
  outfile: 'wallet-bundle.js',
  format: 'iife',
  platform: 'browser',
  target: 'es2020',
  minify: true,
  sourcemap: false,
  define: {
    'process.env.NODE_ENV': '"production"',
    'global': 'globalThis',
  },
});

console.log('✅ wallet-bundle.js built');
