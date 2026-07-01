'use client';

import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { saveToken } from '@/lib/auth';

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [challengeId, setChallengeId] = useState('');
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function sendOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await api.initiatePhone(phone);
      setChallengeId(res.challengeId);
      setStep('otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  }

  async function verifyOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await api.verifyPhone(challengeId, otp);
      saveToken(res.accessToken);
      router.push('/dashboard');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Invalid OTP');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="container" style={{ maxWidth: 420 }}>
      <h1>NutriKit Admin</h1>
      <p>Staff login for menu management</p>
      {step === 'phone' ? (
        <form onSubmit={sendOtp} className="card">
          <label className="field">
            Phone
            <input
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+91XXXXXXXXXX"
              required
            />
          </label>
          <button className="btn" type="submit" disabled={loading}>
            {loading ? 'Sending…' : 'Send OTP'}
          </button>
        </form>
      ) : (
        <form onSubmit={verifyOtp} className="card">
          <label className="field">
            OTP
            <input value={otp} onChange={(e) => setOtp(e.target.value)} required />
          </label>
          <button className="btn" type="submit" disabled={loading}>
            {loading ? 'Verifying…' : 'Login'}
          </button>
        </form>
      )}
      {error && <p style={{ color: '#c1121f' }}>{error}</p>}
    </main>
  );
}
