-- Migration sonrasi hizli dogrulama (SQL Editor'da calistir)
-- Hata yoksa kolonlar ve policy sayilari gorunur.

-- owner_id kolonlari var mi?
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name in ('transactions','installments','loans','budgets','categories','members')
  and column_name = 'owner_id'
order by table_name;

-- RLS acik mi?
select relname as tablo, relrowsecurity as rls_acik
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and relname in ('transactions','installments','loans','budgets','categories','members')
order by relname;

-- Policy listesi (owner_* beklenir)
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname = 'public'
  and tablename in ('transactions','installments','loans','budgets','categories','members')
order by tablename, policyname;

-- Bos owner_id sayisi (backfill gerekebilir)
select 'transactions' as tbl, count(*) filter (where owner_id is null) as bos_owner
from public.transactions
union all
select 'installments', count(*) filter (where owner_id is null) from public.installments
union all
select 'loans', count(*) filter (where owner_id is null) from public.loans
union all
select 'budgets', count(*) filter (where owner_id is null) from public.budgets
union all
select 'categories', count(*) filter (where owner_id is null) from public.categories
union all
select 'members', count(*) filter (where owner_id is null) from public.members;
