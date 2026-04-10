-- members: global UNIQUE(slug) -> UNIQUE(owner_id, slug)
-- Kismi unique index yerine tam UNIQUE constraint (ileride FK icin uygun).

begin;

do $$
declare
  r record;
begin
  for r in
    select c.conname, c.conrelid::regclass as tbl
    from pg_constraint c
    where c.confrelid = 'public.members'::regclass
      and c.contype = 'f'
  loop
    raise notice 'Kaldiriliyor: %.%', r.tbl, r.conname;
    execute format('alter table %s drop constraint %I', r.tbl, r.conname);
  end loop;
end$$;

alter table public.members drop constraint if exists members_slug_key;

delete from public.members where owner_id is null;

delete from public.members m
where m.id in (
  select id from (
    select id, row_number() over (partition by owner_id, slug order by id) as rn
    from public.members
  ) t where rn > 1
);

drop index if exists public.members_owner_id_slug_uidx;
alter table public.members drop constraint if exists members_owner_slug_unique;

alter table public.members
  add constraint members_owner_slug_unique unique (owner_id, slug);

commit;
