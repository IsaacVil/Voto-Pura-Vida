'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';

export default function Login() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    rememberMe: false,
    mfaCode: ''
  });
  const [step, setStep] = useState(1); // 1: credentials, 2: MFA, 3: biometric
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const containerRef = useRef<HTMLDivElement>(null);
  const headerRef = useRef<HTMLDivElement>(null);
  const formRef = useRef<HTMLFormElement>(null);
  const divRef = useRef<HTMLDivElement>(null);  // Animación de entrada - simplificada sin anime.js por ahora
  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.style.opacity = '1';
      containerRef.current.style.transform = 'scale(1)';
    }
  }, []);

  // Animación cuando cambia el step - simplificada
  useEffect(() => {
    const target = step === 3 ? divRef.current : formRef.current;
    if (target) {
      target.style.opacity = '1';
      target.style.transform = 'translateY(0)';
    }
  }, [step]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    // Simular autenticación
    setTimeout(() => {
      if (formData.email && formData.password) {
        setStep(2); // Ir a MFA
      } else {
        setError('Email y contraseña son requeridos');
      }
      setLoading(false);
    }, 1000);
  };

  const handleMFA = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Simular verificación MFA
    setTimeout(() => {
      if (formData.mfaCode === '123456') {
        setStep(3); // Ir a biométrica
      } else {
        setError('Código MFA incorrecto');
      }
      setLoading(false);
    }, 1000);
  };

  const handleBiometric = async () => {
    setLoading(true);

    // Simular verificación biométrica
    setTimeout(() => {
      // Redirigir al dashboard
      window.location.href = '/';
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-cyan-50 via-blue-50 to-teal-50 flex items-center justify-center p-4">      <div 
        ref={containerRef}
        className="bg-white/80 backdrop-blur-sm rounded-2xl shadow-2xl w-full max-w-md border border-white/20 transition-all duration-600 ease-out"
        style={{ opacity: 0, transform: 'scale(0.95)' }}
      >
        {/* Header */}
        <div ref={headerRef} className="px-8 py-6 text-center border-b border-gray-100">
          <div className="w-16 h-16 bg-gradient-to-br from-cyan-600 to-teal-600 rounded-xl flex items-center justify-center mx-auto mb-4 shadow-lg">
            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Voto Pura Vida</h1>
          <p className="text-gray-600">Acceso Seguro al Sistema</p>
        </div>

        {/* Step 1: Credentials */}
        {step === 1 && (
          <form ref={formRef} onSubmit={handleLogin} className="p-8 transition-all duration-300 ease-out" style={{ opacity: 0 }}>
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Correo Electrónico
                </label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-transparent transition-all"
                  placeholder="tu@email.com"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Contraseña
                </label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-transparent transition-all"
                  placeholder="••••••••"
                />
              </div>

              <div className="flex items-center justify-between">
                <label className="flex items-center">
                  <input
                    type="checkbox"
                    name="rememberMe"
                    checked={formData.rememberMe}
                    onChange={handleChange}
                    className="rounded border-gray-300 text-cyan-600 focus:ring-cyan-500"
                  />
                  <span className="ml-2 text-sm text-gray-600">Recordarme</span>
                </label>
                <Link href="/auth/forgot-password" className="text-sm text-cyan-600 hover:text-cyan-700">
                  ¿Olvidaste tu contraseña?
                </Link>
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-xl p-4">
                  <p className="text-red-700 text-sm">{error}</p>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-cyan-600 to-teal-600 text-white py-3 rounded-xl hover:from-cyan-700 hover:to-teal-700 transition-all font-medium disabled:opacity-50 shadow-lg hover:shadow-xl"
              >
                {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
              </button>

              <div className="text-center">
                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-gray-300" />
                  </div>
                  <div className="relative flex justify-center text-sm">
                    <span className="px-2 bg-white text-gray-500">o continúa con</span>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <button
                  type="button"
                  className="flex items-center justify-center px-4 py-3 border border-gray-300 rounded-xl hover:bg-gray-50 transition-colors"
                >
                  <svg className="w-5 h-5 text-blue-600" viewBox="0 0 24 24">
                    <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>
                  <span className="ml-2 text-sm font-medium text-gray-700">Google</span>
                </button>
                <button
                  type="button"
                  className="flex items-center justify-center px-4 py-3 border border-gray-300 rounded-xl hover:bg-gray-50 transition-colors"
                >
                  <svg className="w-5 h-5 text-blue-600" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                  </svg>
                  <span className="ml-2 text-sm font-medium text-gray-700">Facebook</span>
                </button>
              </div>
            </div>
          </form>
        )}

        {/* Step 2: MFA */}
        {step === 2 && (
          <form ref={formRef} onSubmit={handleMFA} className="p-8 transition-all duration-300 ease-out" style={{ opacity: 0 }}>
            <div className="space-y-6">
              <div className="text-center">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <h3 className="text-lg font-medium text-gray-800 mb-2">
                  Verificación en Dos Pasos
                </h3>
                <p className="text-gray-600 text-sm mb-6">
                  Hemos enviado un código de 6 dígitos a tu teléfono móvil registrado.
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Código de Verificación
                </label>
                <input
                  type="text"
                  name="mfaCode"
                  value={formData.mfaCode}
                  onChange={handleChange}
                  required
                  maxLength={6}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-transparent text-center text-2xl tracking-widest transition-all"
                  placeholder="123456"
                />
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-xl p-4">
                  <p className="text-red-700 text-sm">{error}</p>
                </div>
              )}

              <div className="flex space-x-4">
                <button
                  type="button"
                  onClick={() => setStep(1)}
                  className="flex-1 border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-all font-medium"
                >
                  Volver
                </button>
                <button
                  type="submit"
                  disabled={loading || formData.mfaCode.length !== 6}
                  className="flex-1 bg-gradient-to-r from-cyan-600 to-teal-600 text-white py-3 rounded-xl hover:from-cyan-700 hover:to-teal-700 transition-all font-medium disabled:opacity-50 shadow-lg hover:shadow-xl"
                >
                  {loading ? 'Verificando...' : 'Verificar'}
                </button>
              </div>

              <div className="text-center">
                <button
                  type="button"
                  className="text-sm text-cyan-600 hover:text-cyan-700"
                >
                  ¿No recibiste el código? Reenviar
                </button>
              </div>
            </div>
          </form>
        )}

        {/* Step 3: Biometric */}
        {step === 3 && (
          <div ref={divRef} className="p-8 transition-all duration-300 ease-out" style={{ opacity: 0 }}>
            <div className="space-y-6">
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                  </svg>
                </div>
                <h3 className="text-lg font-medium text-gray-800 mb-2">
                  Verificación Biométrica
                </h3>
                <p className="text-gray-600 text-sm mb-6">
                  Completa tu autenticación con verificación biométrica para acceder de forma segura.
                </p>
              </div>

              <div className="bg-gradient-to-br from-cyan-50 to-blue-50 rounded-xl p-6 text-center">
                <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <div className="w-16 h-16 border-4 border-cyan-300 border-t-cyan-600 rounded-full animate-spin"></div>
                </div>
                <p className="text-gray-700 font-medium mb-2">Preparando escáner biométrico...</p>
                <p className="text-gray-600 text-sm">
                  Coloca tu dedo en el sensor o mira directamente a la cámara
                </p>
              </div>

              <div className="flex space-x-4">
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  className="flex-1 border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-all font-medium"
                >
                  Volver
                </button>
                <button
                  onClick={handleBiometric}
                  disabled={loading}
                  className="flex-1 bg-gradient-to-r from-cyan-600 to-blue-600 text-white py-3 rounded-xl hover:from-cyan-700 hover:to-blue-700 transition-all font-medium disabled:opacity-50 shadow-lg hover:shadow-xl"
                >
                  {loading ? 'Verificando...' : 'Iniciar Verificación'}
                </button>
              </div>

              <div className="bg-amber-50 border border-amber-200 rounded-xl p-4">
                <div className="flex items-start">
                  <svg className="w-5 h-5 text-amber-600 mr-3 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                  <div>
                    <p className="text-amber-800 text-sm font-medium">Seguridad Máxima</p>
                    <p className="text-amber-700 text-sm">
                      Tus datos biométricos están cifrados y nunca salen de tu dispositivo.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Footer */}
        <div className="px-8 py-6 bg-gray-50/50 rounded-b-2xl text-center border-t border-gray-100">
          <p className="text-gray-600 text-sm">
            ¿No tienes una cuenta?{' '}
            <Link href="/auth/register" className="text-cyan-600 hover:text-cyan-700 font-medium">
              Registrarse
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
