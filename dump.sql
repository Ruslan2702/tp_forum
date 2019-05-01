--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.16
-- Dumped by pg_dump version 9.5.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: decr_votes_count(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.decr_votes_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE threads
SET votes = votes - OLD.voice
WHERE id = OLD.thread;
RETURN OLD;
END;
$$;


ALTER FUNCTION public.decr_votes_count() OWNER TO ruslan_shahaev;

--
-- Name: incr_votes_count(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.incr_votes_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE threads
SET votes = votes + NEW.voice
WHERE id = NEW.thread;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.incr_votes_count() OWNER TO ruslan_shahaev;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: users; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    nickname public.citext NOT NULL,
    fullname character varying(100) NOT NULL,
    about text,
    email public.citext,
    CONSTRAINT users_about_check CHECK ((about <> ''::text)),
    CONSTRAINT users_email_check CHECK ((email OPERATOR(public.<>) ''::public.citext)),
    CONSTRAINT users_fullname_check CHECK (((fullname)::text <> ''::text)),
    CONSTRAINT users_nickname_check CHECK ((nickname OPERATOR(public.<>) ''::public.citext))
);


ALTER TABLE public.users OWNER TO ruslan_shahaev;

--
-- Name: test(integer); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.test(p integer) RETURNS SETOF public.users
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF p = 1 THEN
    RETURN QUERY SELECT * FROM users;
  END IF;
  RETURN;
END;
$$;


ALTER FUNCTION public.test(p integer) OWNER TO ruslan_shahaev;

--
-- Name: update_threads_count(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.update_threads_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE forums
SET threads = threads + 1
WHERE slug = NEW.forum;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_threads_count() OWNER TO ruslan_shahaev;

--
-- Name: for_posts; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.for_posts
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.for_posts OWNER TO ruslan_shahaev;

--
-- Name: forums; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.forums (
    id bigint NOT NULL,
    title character varying(150) NOT NULL,
    user_nickname public.citext NOT NULL,
    slug public.citext NOT NULL,
    posts bigint DEFAULT 0,
    threads bigint DEFAULT 0
);


ALTER TABLE public.forums OWNER TO ruslan_shahaev;

--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forums_id_seq OWNER TO ruslan_shahaev;

--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.forums_id_seq OWNED BY public.forums.id;


--
-- Name: forums_user_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.forums_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forums_user_id_seq OWNER TO ruslan_shahaev;

--
-- Name: forums_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.forums_user_id_seq OWNED BY public.forums.user_nickname;


--
-- Name: my_serial_name; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.my_serial_name
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.my_serial_name OWNER TO ruslan_shahaev;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    parent bigint DEFAULT 0,
    author public.citext,
    message text,
    isedited boolean DEFAULT false,
    forum character varying(100),
    thread bigint,
    created timestamp with time zone DEFAULT now(),
    path integer[]
);


ALTER TABLE public.posts OWNER TO ruslan_shahaev;

--
-- Name: posts_author_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.posts_author_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_author_seq OWNER TO ruslan_shahaev;

--
-- Name: posts_author_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.posts_author_seq OWNED BY public.posts.author;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_id_seq OWNER TO ruslan_shahaev;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: test; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.test (
    id integer NOT NULL,
    str character varying
);


ALTER TABLE public.test OWNER TO ruslan_shahaev;

--
-- Name: test_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_id_seq OWNER TO ruslan_shahaev;

--
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.test_id_seq OWNED BY public.test.id;


--
-- Name: threads; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.threads (
    id bigint NOT NULL,
    author public.citext NOT NULL,
    message text NOT NULL,
    forum public.citext NOT NULL,
    votes bigint DEFAULT 0,
    slug public.citext,
    created timestamp with time zone DEFAULT now(),
    title public.citext
);


ALTER TABLE public.threads OWNER TO ruslan_shahaev;

--
-- Name: threads_author_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.threads_author_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.threads_author_seq OWNER TO ruslan_shahaev;

--
-- Name: threads_author_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.threads_author_seq OWNED BY public.threads.author;


--
-- Name: threads_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.threads_id_seq OWNER TO ruslan_shahaev;

--
-- Name: threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.threads_id_seq OWNED BY public.threads.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO ruslan_shahaev;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: ruslan_shahaev
--

CREATE TABLE public.votes (
    id bigint NOT NULL,
    user_nickname public.citext NOT NULL,
    voice smallint NOT NULL,
    thread bigint
);


ALTER TABLE public.votes OWNER TO ruslan_shahaev;

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.votes_id_seq OWNER TO ruslan_shahaev;

--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: votes_user_id_seq; Type: SEQUENCE; Schema: public; Owner: ruslan_shahaev
--

CREATE SEQUENCE public.votes_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.votes_user_id_seq OWNER TO ruslan_shahaev;

--
-- Name: votes_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ruslan_shahaev
--

ALTER SEQUENCE public.votes_user_id_seq OWNED BY public.votes.user_nickname;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.forums ALTER COLUMN id SET DEFAULT nextval('public.forums_id_seq'::regclass);


--
-- Name: user_nickname; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.forums ALTER COLUMN user_nickname SET DEFAULT nextval('public.forums_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: author; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.posts ALTER COLUMN author SET DEFAULT nextval('public.posts_author_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.test ALTER COLUMN id SET DEFAULT nextval('public.test_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.threads ALTER COLUMN id SET DEFAULT nextval('public.threads_id_seq'::regclass);


--
-- Name: author; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.threads ALTER COLUMN author SET DEFAULT nextval('public.threads_author_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: user_nickname; Type: DEFAULT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.votes ALTER COLUMN user_nickname SET DEFAULT nextval('public.votes_user_id_seq'::regclass);


--
-- Name: for_posts; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.for_posts', 13, true);


--
-- Data for Name: forums; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.forums (id, title, user_nickname, slug, posts, threads) FROM stdin;
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 60771, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Name: my_serial_name; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.my_serial_name', 4, true);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path) FROM stdin;
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 3, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 4487289, true);


--
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.test (id, str) FROM stdin;
1	one
2	two
3	one
4	two
5	one
6	two
7	one
8	two
\.


--
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.test_id_seq', 8, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 259210, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 234535, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1625450, true);


--
-- Name: votes_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_user_id_seq', 1, false);


--
-- Name: forums_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: forums_slug_key; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_slug_key UNIQUE (slug);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: test_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.test
    ADD CONSTRAINT test_pkey PRIMARY KEY (id);


--
-- Name: threads_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_nickname_key; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nickname_key UNIQUE (nickname);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: posts_expr_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_expr_idx ON public.posts USING btree (((path || (id)::integer)));


--
-- Name: posts_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_forum_idx ON public.posts USING btree (forum);


--
-- Name: posts_id_path_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_id_path_idx ON public.posts USING btree (id, path);


--
-- Name: posts_id_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_id_thread_idx ON public.posts USING btree (id, thread);


--
-- Name: threads_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_forum_idx ON public.threads USING btree (forum);


--
-- Name: threads_slug_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_slug_idx ON public.threads USING btree (slug);


--
-- Name: votes_user_nickname_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX votes_user_nickname_thread_idx ON public.votes USING btree (user_nickname, thread);


--
-- Name: forum_threads_increment; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER forum_threads_increment AFTER INSERT ON public.threads FOR EACH ROW EXECUTE PROCEDURE public.update_threads_count();


--
-- Name: thread_votes_decr; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER thread_votes_decr AFTER DELETE ON public.votes FOR EACH ROW EXECUTE PROCEDURE public.decr_votes_count();


--
-- Name: thread_votes_incr; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER thread_votes_incr AFTER INSERT ON public.votes FOR EACH ROW EXECUTE PROCEDURE public.incr_votes_count();


--
-- Name: forums_user_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_user_nickname_fkey FOREIGN KEY (user_nickname) REFERENCES public.users(nickname);


--
-- Name: threads_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_author_fkey FOREIGN KEY (author) REFERENCES public.users(nickname);


--
-- Name: threads_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_forum_fkey FOREIGN KEY (forum) REFERENCES public.forums(slug);


--
-- Name: votes_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_thread_fkey FOREIGN KEY (thread) REFERENCES public.threads(id);


--
-- Name: votes_user_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ruslan_shahaev
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_user_nickname_fkey FOREIGN KEY (user_nickname) REFERENCES public.users(nickname);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

