-- categories: global UNIQUE(ad) -> kullanici bazli UNIQUE(owner_id, ad)
-- FK, CREATE UNIQUE INDEX ... WHERE (kismi index) uzerine kurulamaz; tam UNIQUE constraint gerekir.
-- transactions_kategori_fkey once kaldirilir.

-- Calistirmadan once yedek al.

begin;

-- 1) categories'e giden FK'leri kaldir
do $$
declare
  r record;
begin
  for r in
    select c.conname, c.conrelid::regclass as tbl
    from pg_constraint c
    where c.confrelid = 'public.categories'::regclass
      and c.contype = 'f'
  loop
    raise notice 'Kaldiriliyor: %.%', r.tbl, r.conname;
    execute format('alter table %s drop constraint %I', r.tbl, r.conname);
  end loop;
end$$;

-- 2) Eski unique (ad)
alter table public.categories drop constraint if exists categories_ad_key;

-- 3) owner_id bos kategori satirlari FK icin uygun degil; sil veya elle owner ata
--    (Eski veriyi korumak istiyorsan once UPDATE ile owner_id doldur)
delete from public.categories where owner_id is null;

-- 4) Ayni owner + ayni ad tekrari
delete from public.categories c
where c.id in (
  select id from (
    select id, row_number() over (partition by owner_id, ad order by id) as rn
    from public.categories
  ) t where rn > 1
);

-- 5) Kismi index kaldir; tam UNIQUE constraint olustur (FK bunu referans alir)
drop index if exists public.categories_owner_id_ad_uidx;
alter table public.categories drop constraint if exists categories_owner_ad_unique;

alter table public.categories
  add constraint categories_owner_ad_unique unique (owner_id, ad);

-- 6) transactions: (owner_id, kategori) -> categories(owner_id, ad)
--    Uyumsuz satir varsa FK basarisiz olur; asagidaki SELECT ile kontrol et.
alter table public.transactions
  add constraint transactions_kategori_fkey
  foreign key (owner_id, kategori)
  references public.categories (owner_id, ad);

commit;

-- Sorun cikarsa orphan islemler:
-- select t.* from transactions t
-- left join categories c on c.owner_id = t.owner_id and c.ad = t.kategori
-- where t.owner_id is not null and c.id is null;
