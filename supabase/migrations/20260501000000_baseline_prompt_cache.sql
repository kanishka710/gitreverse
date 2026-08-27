-- Baseline schema: create prompt_cache table (predates the numbered migrations)
CREATE TABLE IF NOT EXISTS public.prompt_cache (
  id          bigserial PRIMARY KEY,
  owner       text NOT NULL,
  repo        text NOT NULL,
  prompt      text NOT NULL,
  cached_at   timestamptz NOT NULL DEFAULT now(),
  views       integer NOT NULL DEFAULT 0,
  CONSTRAINT prompt_cache_owner_repo_key UNIQUE (owner, repo)
);

ALTER TABLE public.prompt_cache ENABLE ROW LEVEL SECURITY;

-- Allow anonymous reads (library page, sitemap, etc.)
CREATE POLICY "prompt_cache_read_public"
  ON public.prompt_cache FOR SELECT USING (true);

-- Allow service role to write
CREATE POLICY "prompt_cache_insert_service"
  ON public.prompt_cache FOR INSERT WITH CHECK (true);

CREATE POLICY "prompt_cache_update_service"
  ON public.prompt_cache FOR UPDATE USING (true);
