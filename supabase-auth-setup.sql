-- Aile Cuzdani: Auth + owner bazli veri izolasyonu
-- Bu scripti Supabase SQL Editor'da bir kez calistir.
--
-- ONEMLI: Bu tablolar public semasinda yoksa once migration ile olusturulmalidir:
-- transactions, installments, loans, budgets, categories, members
--
-- Eski "herkese acik" RLS policy'lerin varsa once manuel silin; yoksa policy cakisabilir.
-- Dogrulama icin: supabase-verify-after-migration.sql

begin;

-- 1) owner_id kolonlari (kullaniciya ait tablolar)
alter table if exists public.transactions add column if not exists owner_id uuid;
alter table if exists public.installments add column if not exists owner_id uuid;
alter table if exists public.loans add column if not exists owner_id uuid;
alter table if exists public.budgets add column if not exists owner_id uuid;
alter table if exists public.categories add column if not exists owner_id uuid;
alter table if exists public.members add column if not exists owner_id uuid;

-- 2) FK'ler (auth.users'a bagli; cift ekleme hatasina karsi exception ile korunur)
do $$
begin
  if to_regclass('public.transactions') is not null then
    if not exists (select 1 from pg_constraint where conname = 'transactions_owner_id_fkey') then
      begin
        alter table public.transactions
          add constraint transactions_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;

  if to_regclass('public.installments') is not null then
    if not exists (select 1 from pg_constraint where conname = 'installments_owner_id_fkey') then
      begin
        alter table public.installments
          add constraint installments_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;

  if to_regclass('public.loans') is not null then
    if not exists (select 1 from pg_constraint where conname = 'loans_owner_id_fkey') then
      begin
        alter table public.loans
          add constraint loans_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;

  if to_regclass('public.budgets') is not null then
    if not exists (select 1 from pg_constraint where conname = 'budgets_owner_id_fkey') then
      begin
        alter table public.budgets
          add constraint budgets_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;

  if to_regclass('public.categories') is not null then
    if not exists (select 1 from pg_constraint where conname = 'categories_owner_id_fkey') then
      begin
        alter table public.categories
          add constraint categories_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;

  if to_regclass('public.members') is not null then
    if not exists (select 1 from pg_constraint where conname = 'members_owner_id_fkey') then
      begin
        alter table public.members
          add constraint members_owner_id_fkey
          foreign key (owner_id) references auth.users(id) on delete cascade;
      exception when duplicate_object then null;
      end;
    end if;
  end if;
end$$;

-- 3) Performans indexleri
create index if not exists idx_transactions_owner_id on public.transactions(owner_id);
create index if not exists idx_installments_owner_id on public.installments(owner_id);
create index if not exists idx_loans_owner_id on public.loans(owner_id);
create index if not exists idx_budgets_owner_id on public.budgets(owner_id);
create index if not exists idx_categories_owner_id on public.categories(owner_id);
create index if not exists idx_members_owner_id on public.members(owner_id);

-- 4) RLS aktif et
alter table if exists public.transactions enable row level security;
alter table if exists public.installments enable row level security;
alter table if exists public.loans enable row level security;
alter table if exists public.budgets enable row level security;
alter table if exists public.categories enable row level security;
alter table if exists public.members enable row level security;

-- 5) Eski policy'leri temizle (idempotent)
drop policy if exists "transactions_owner_select" on public.transactions;
drop policy if exists "transactions_owner_insert" on public.transactions;
drop policy if exists "transactions_owner_update" on public.transactions;
drop policy if exists "transactions_owner_delete" on public.transactions;

drop policy if exists "installments_owner_select" on public.installments;
drop policy if exists "installments_owner_insert" on public.installments;
drop policy if exists "installments_owner_update" on public.installments;
drop policy if exists "installments_owner_delete" on public.installments;

drop policy if exists "loans_owner_select" on public.loans;
drop policy if exists "loans_owner_insert" on public.loans;
drop policy if exists "loans_owner_update" on public.loans;
drop policy if exists "loans_owner_delete" on public.loans;

drop policy if exists "budgets_owner_select" on public.budgets;
drop policy if exists "budgets_owner_insert" on public.budgets;
drop policy if exists "budgets_owner_update" on public.budgets;
drop policy if exists "budgets_owner_delete" on public.budgets;

drop policy if exists "categories_owner_select" on public.categories;
drop policy if exists "categories_owner_insert" on public.categories;
drop policy if exists "categories_owner_update" on public.categories;
drop policy if exists "categories_owner_delete" on public.categories;

drop policy if exists "members_owner_select" on public.members;
drop policy if exists "members_owner_insert" on public.members;
drop policy if exists "members_owner_update" on public.members;
drop policy if exists "members_owner_delete" on public.members;

-- 6) Owner policy'leri
create policy "transactions_owner_select" on public.transactions
for select using (auth.uid() = owner_id);
create policy "transactions_owner_insert" on public.transactions
for insert with check (auth.uid() = owner_id);
create policy "transactions_owner_update" on public.transactions
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "transactions_owner_delete" on public.transactions
for delete using (auth.uid() = owner_id);

create policy "installments_owner_select" on public.installments
for select using (auth.uid() = owner_id);
create policy "installments_owner_insert" on public.installments
for insert with check (auth.uid() = owner_id);
create policy "installments_owner_update" on public.installments
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "installments_owner_delete" on public.installments
for delete using (auth.uid() = owner_id);

create policy "loans_owner_select" on public.loans
for select using (auth.uid() = owner_id);
create policy "loans_owner_insert" on public.loans
for insert with check (auth.uid() = owner_id);
create policy "loans_owner_update" on public.loans
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "loans_owner_delete" on public.loans
for delete using (auth.uid() = owner_id);

create policy "budgets_owner_select" on public.budgets
for select using (auth.uid() = owner_id);
create policy "budgets_owner_insert" on public.budgets
for insert with check (auth.uid() = owner_id);
create policy "budgets_owner_update" on public.budgets
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "budgets_owner_delete" on public.budgets
for delete using (auth.uid() = owner_id);

create policy "categories_owner_select" on public.categories
for select using (auth.uid() = owner_id);
create policy "categories_owner_insert" on public.categories
for insert with check (auth.uid() = owner_id);
create policy "categories_owner_update" on public.categories
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "categories_owner_delete" on public.categories
for delete using (auth.uid() = owner_id);

create policy "members_owner_select" on public.members
for select using (auth.uid() = owner_id);
create policy "members_owner_insert" on public.members
for insert with check (auth.uid() = owner_id);
create policy "members_owner_update" on public.members
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "members_owner_delete" on public.members
for delete using (auth.uid() = owner_id);

-- 7) NOT NULL kilidi (opsiyonel ama onerilir)
-- Eger eski satirlarda owner_id bos ise once backfill yapin.
-- alter table public.transactions alter column owner_id set not null;
-- alter table public.installments alter column owner_id set not null;
-- alter table public.loans alter column owner_id set not null;
-- alter table public.budgets alter column owner_id set not null;
-- alter table public.categories alter column owner_id set not null;
-- alter table public.members alter column owner_id set not null;

commit;
