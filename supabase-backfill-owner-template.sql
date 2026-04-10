-- MEVCUT VERIYI TEK KULLANICIYA BAGLAMA (sablon)
-- 1) Supabase Dashboard > Authentication > Users icinden hedef kullanicinin UUID'sini kopyala.
-- 2) Asagidaki 'PASTE_USER_UUID_HERE' yerine yapistir.
-- 3) Tek seferde calistir.

-- update public.transactions set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;
-- update public.installments set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;
-- update public.loans set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;
-- update public.budgets set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;
-- update public.categories set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;
-- update public.members set owner_id = 'PASTE_USER_UUID_HERE'::uuid where owner_id is null;

-- Backfill sonrasi (istege bagli) NOT NULL:
-- alter table public.transactions alter column owner_id set not null;
-- alter table public.installments alter column owner_id set not null;
-- alter table public.loans alter column owner_id set not null;
-- alter table public.budgets alter column owner_id set not null;
-- alter table public.categories alter column owner_id set not null;
-- alter table public.members alter column owner_id set not null;
