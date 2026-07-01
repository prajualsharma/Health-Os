'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { api, CafeSection, CatalogItem } from '@/lib/api';
import { isLoggedIn } from '@/lib/auth';

export default function SectionsPage() {
  const { kitchenId } = useParams<{ kitchenId: string }>();
  const router = useRouter();
  const [sections, setSections] = useState<CafeSection[]>([]);
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [error, setError] = useState('');
  const [saving, setSaving] = useState('');

  useEffect(() => {
    if (!isLoggedIn()) {
      router.replace('/login');
      return;
    }
    Promise.all([
      api.listSections(kitchenId),
      api.listCatalogItems(kitchenId, 'CAFE'),
    ])
      .then(([s, i]) => {
        setSections(s);
        setItems(i);
      })
      .catch((e) => setError(e.message));
  }, [kitchenId, router]);

  function toggleItem(sectionId: string, itemId: string) {
    setSections((prev) =>
      prev.map((s) => {
        if (s.id !== sectionId) return s;
        const has = s.itemIds.includes(itemId);
        const itemIds = has ? s.itemIds.filter((id) => id !== itemId) : [...s.itemIds, itemId];
        return { ...s, itemIds };
      }),
    );
  }

  async function save(section: CafeSection) {
    setSaving(section.id);
    try {
      await api.setSectionItems(section.id, section.itemIds);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Save failed');
    } finally {
      setSaving('');
    }
  }

  return (
    <>
      <nav className="nav">
        <Link href={`/kitchens/${kitchenId}/menu`}>← Menu</Link>
        <strong>Section manager</strong>
      </nav>
      <main className="container">
        <h1>Cafe sections</h1>
        <p>Assign published cafe items to merchandising carousels.</p>
        {error && <p style={{ color: '#c1121f' }}>{error}</p>}
        {sections.map((section) => (
          <div key={section.id} className="card" style={{ marginBottom: 16 }}>
            <h3>{section.title}</h3>
            <p style={{ color: '#5c6b5c', fontSize: 13 }}>{section.sectionKey}</p>
            <div style={{ display: 'grid', gap: 6 }}>
              {items.map((item) => (
                <label key={item.id}>
                  <input
                    type="checkbox"
                    checked={section.itemIds.includes(item.id)}
                    onChange={() => toggleItem(section.id, item.id)}
                  />{' '}
                  {item.emoji} {item.name}
                </label>
              ))}
            </div>
            <button className="btn" style={{ marginTop: 12 }} onClick={() => save(section)} disabled={!!saving}>
              {saving === section.id ? 'Saving…' : 'Save section'}
            </button>
          </div>
        ))}
      </main>
    </>
  );
}
