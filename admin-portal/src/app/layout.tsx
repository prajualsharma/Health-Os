import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'NutriKit Admin',
  description: 'Merchant catalog admin for NutriKit',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
