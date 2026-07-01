const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8080';

export type CatalogItem = {
  id: string;
  kitchenId: string;
  name: string;
  description: string;
  mealCategory: string;
  priceCents: number;
  originalPriceCents?: number;
  veg: boolean;
  available: boolean;
  status: 'DRAFT' | 'PUBLISHED';
  channelCafe: boolean;
  channelMealPlan: boolean;
  channelRecipe: boolean;
  emoji: string;
  imageUrl: string;
  portion: string;
  prepTimeMins: number;
  calories: number;
  protein: number;
  isAddOn: boolean;
  isMostLoved: boolean;
  isHighlyReordered: boolean;
  kitchenName: string;
};

export type CafeSection = {
  id: string;
  sectionKey: string;
  title: string;
  sortOrder: number;
  itemIds: string[];
  items: CatalogItem[];
};

export type Kitchen = {
  id: string;
  name: string;
  city: string;
};

function authHeaders(): HeadersInit {
  if (typeof window === 'undefined') return {};
  const token = localStorage.getItem('staff_token');
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...authHeaders(),
      ...init?.headers,
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(body || res.statusText);
  }
  if (res.status === 204) return undefined as T;
  return res.json() as Promise<T>;
}

export const api = {
  initiatePhone: (phone: string) =>
    request<{ challengeId: string }>('/auth/staff/phone/initiate?clientId=kitchen', {
      method: 'POST',
      body: JSON.stringify({ phone }),
    }),

  verifyPhone: (challengeId: string, otp: string) =>
    request<{ accessToken: string; refreshToken: string }>(
      '/auth/staff/phone/verify?clientId=kitchen',
      { method: 'POST', body: JSON.stringify({ challengeId, otp }) },
    ),

  listKitchens: () => request<Kitchen[]>('/kitchen/kitchens'),

  listCatalogItems: (kitchenId: string, channel = 'CAFE') =>
    request<CatalogItem[]>(
      `/kitchen/catalog/kitchens/${kitchenId}/items?channel=${channel}`,
    ),

  getCatalogItem: (itemId: string) =>
    request<CatalogItem>(`/kitchen/catalog/items/${itemId}`),

  createCatalogItem: (kitchenId: string, body: Partial<CatalogItem>) =>
    request<CatalogItem>(`/kitchen/catalog/kitchens/${kitchenId}/items`, {
      method: 'POST',
      body: JSON.stringify(body),
    }),

  updateCatalogItem: (itemId: string, body: Partial<CatalogItem>) =>
    request<CatalogItem>(`/kitchen/catalog/items/${itemId}`, {
      method: 'PATCH',
      body: JSON.stringify(body),
    }),

  deleteCatalogItem: (itemId: string) =>
    request<void>(`/kitchen/catalog/items/${itemId}`, { method: 'DELETE' }),

  listSections: (kitchenId: string) =>
    request<CafeSection[]>(`/kitchen/catalog/kitchens/${kitchenId}/sections`),

  setSectionItems: (sectionId: string, itemIds: string[]) =>
    request<void>(`/kitchen/catalog/sections/${sectionId}/items`, {
      method: 'PUT',
      body: JSON.stringify({ itemIds }),
    }),

  upsertRecipe: (
    itemId: string,
    body: {
      slot: string;
      cookTimeMins: number;
      difficulty: string;
      fitsGoal: boolean;
      ingredients: { name: string; grams: number }[];
      steps: string[];
    },
  ) =>
    request(`/kitchen/catalog/items/${itemId}/recipe`, {
      method: 'PUT',
      body: JSON.stringify(body),
    }),
};
