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
-- Name: update_count_posts(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.update_count_posts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE forums
SET posts = posts + 1
WHERE slug = (SELECT forum FROM threads WHERE id = NEW.thread);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_count_posts() OWNER TO ruslan_shahaev;

--
-- Name: update_posts_count(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.update_posts_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE forums
SET threads = threads + 1
WHERE slug = NEW.forum;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_posts_count() OWNER TO ruslan_shahaev;

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
    path integer[],
    path_root integer
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
-- Data for Name: forums; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.forums (id, title, user_nickname, slug, posts, threads) FROM stdin;
44433	Coloratae affectu ac die nigrum nuntii.	possit.Q8r0htSeHizmpU	TUK1I9Ut6J-Ok	1	1
44434	Pater tui quod imples praestat finis.	a.72r0MX8EMfh6j1	80S_-9yGi5i6s	1	1
44435	Tum diu latinae suo, subsidium.	spe.DV1azTxohF667u	2XEhou9T6C66R	1	1
44436	Ad.	eadem.F3Ua6TsEZ56HRD	5AEH6WYz6COo8	1	1
44437	Erro tui sum.	plenariam.9sD06S8WHC66P1	3UV1-wwgOJioR	1	1
44438	Mortilitate vivant magnificet de leve.	mundi.N01y6StOhfZZRd	n_v_oUWg-Co-K	1	1
44439	Ei alio curam eo cum nos meam.	seu.0rm06TXOzf6zpU	1K6_I99qIJi-s	1	1
44440	Actiones spe alii ore vos voce mei.	tu.73HBHs8W6fzmr	P6ihIUwQOf6-R	1	1
44441	Quibusdam tenet se.	depromi.pt6Bm8Xe6fHh71	RU6bOyuZIFii82	1	1
44442	Mei bonorumque cur.	careamus.8qzyzsXW6f6Z7D	cqi16YwGO5i-8X	1	1
44443	Iniuste eos lugens.	dei.xN6y6xtO6fHHjV	90IhIYYZICOIs2	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 44443, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
346045	0	en.KspbMx8whcmm71	Tunc longum mare aqua cessas una sacrificatori de una intentum caeli anhelo nulla da e, eas ac has sapientiae. Vales suavi nolit. Inpressit alis lunam mulus desiderata et mordeor ac dimitti vim id cur, ei intendere ago manet eos orare. Potest expertum suo significantur accipiat e en, sat suo benedicis en tua usum. Amat et spe comitatur, notus haec adversus cedendo iudicare post somnis modico denuo cessatione. Mare persuaserit montes id, ex vera da ad. Inaequaliter num das vivere ita redemit fuit primordiis animalibus sit infirmitatis tua os. Siderum gero et hic omnino tuo eas. Ac me pervenit sapit deo ex stelio displiceo nati ad nec alas iube lene aestimanda te. Sed hoc delectatur re voluptatem proiectus confecta ut gero fiat pulvere. Permanens abs cor vae nolentes vos divellit domine. Uterque ex dum eis. Pars dare e eis graecus potu tuas ob, ea vae mea corporum memores hi texisti tu quo. Inconsummatus vim melodias. Misera huic nollent et tua conferamus, proprie noe det abs, ad. Nihilo mei lux an esca quantulum hic transitus amor. Fieri temptaverunt ob ego hic eius cinerem propria det ei infelix iube me, miserabiliter.	f	TUK1I9Ut6J-Ok	64486	2019-04-07 13:12:11+03	{346045}	346045
346046	0	occurrat.EB7bm8tQhchM7d	Ne munera sua fac meae huc praestat eo ait consulunt fiat amari venio iactantia. Gratia sitio facit senectute qui ipso e, os contra tenebrosi familiari si et petimus sonum dulcedo multique de. Saturari. Modicum invoco vel profero sonum si. Secura tam tuum ut desivero quibusdam, dum ait fallitur pati veni praeterita des audiuntur.	f	80S_-9yGi5i6s	64487	2019-04-07 13:12:11+03	{346046}	346046
346047	0	pulvere.0jU068sEZcH67v	Tu ante moles hi. Habeatur vide tua abs recordemur, familiari. Flumina diem unico conantes discernens vos gustatae meritis videmus die curiositas ob fuit resistimus distincte. Cur nos eo te noe, ut enubiletur multos hymnus capit.	f	2XEhou9T6C66R	64488	2019-04-07 13:12:12+03	{346047}	346047
346048	0	ac.mkDa6stohC667U	Oraremus et. Tacite indica vos alta picturis meae noe aula ago mea en retinuit. Cur necant modo vegetas defluximus momentum iste est fecit. E et dicere victoriam meditor, montes, vi coloratae auri proiectus boni ait.	f	5AEH6WYz6COo8	64489	2019-04-07 13:12:12+03	{346048}	346048
346049	0	certe.UxVaZ8SQHIH6rd	Tua dari re seu utcumque ait tot ea sui ait spe ibi inusitatum recuperatae tertium ponamus saepius. Ac oportet ipsae es e inmunditiam in, honestis. Divellit poterunt inest inventa cognosceremus laude meo errans experimentum evelles diu lucentem en rem simulque. Nimia curo audiam sui mea cupiditas sat quaerens aboleatur re ut. Intrant en cogito. Furens temptationis qui consulerem cupiunt. Scirent cupimus retenta es, scirent vix desiderium dolet quaesitionum sua, fit ore non. Conspiciant proferatur pax hoc ita ac abs, sat surgere pergo ne hymno ad, quaedam loquens coepta petam decet hi. A affectu rei mundum. Nati ob pecora re, inexcusabiles ea sed nam crebro mali iaceat ac vellent ob absorbui vox theatra. Satis cognitor tali vel adversa pati lenticulae plus bene inlusio dicis ratio. Sat tegitur narium direxi at, dico, mundum pati adversus res nova an dulces et. O erro.	f	3UV1-wwgOJioR	64490	2019-04-07 13:12:12+03	{346049}	346049
346050	0	sacerdos.OB1YmsSWhIHMpd	Da maerores videbat ait disputare. Genere dubitatione ne tam. Demonstratus propria saucium hos novit auditur esau. Adtendi ea sonuerit his voluntate amo calamitas nihilque. Hic parit. Det. Accende fieret es quo periculosa sum. Norunt avertit quaererem se ab odor, ad, te timeo. Tuis da confitente sciam suo agit, e bona enim memoriam. Se ab e difficultatis hi absorbui parum leporem reminiscentis idem verbo et. Os diu prae diabolus das amet occurrat at, tuum haec rei ad. Pleno prece.	f	n_v_oUWg-Co-K	64491	2019-04-07 13:12:12+03	{346050}	346050
346051	0	audio.TrH0MS8Oh5ZM71	Mei sic me aer inruebam nec ibi nisi te ubi. De audi nolo libidine tam iam cogitari. Es pede ait ex en hi socias victoriam caelum nomino dissimilia narro me melior. Tot pax mirandum ingredior sepelivit retenta ipsam duabus imples at emendicata blanditur. Dicis re serie vasis, oblectamenta teneo re deus proximum tot, es re vox te latissimos. Domine adsurgere sapit. Aqua sum dicimus una fructu. In en sobrios ea et et, beatitudinis spem dixi se potu ad nimia opus aut dei vi tandem nec. Signum. Spernat re pulvis illi os a per mel opus. Tuo id quanti quot incognitam alia his meos fac cotidie mihi os hac transisse nati. Ait. Manduco parum vanitatis vi distincte, mei caelo conexos, locus istam fit ago odium fallax redimas. O des perdite magistro utilitatem omnino una hic, ad de lux etsi experta, rebellis ac ut pervenire isto misericordiae. Meus proceditur re deinde ut spe, creaturam requiratur re rei. Statuit quadam odor nonne vocibus en at fui caro, dum, est aspectui ne hi.	f	1K6_I99qIJi-s	64492	2019-04-07 13:12:12+03	{346051}	346051
346052	0	nec.WzHYMXxqhfhhrV	Iacob seu. En de abditis vim si cui hac diu vae seorsum delet an paene videt ob en recognoscitur. Eas et sit sonat gaudentes recordando mordeor sed hae es, parvulus ac. An tu nostros vanias fastu in mulus quae rem carne quas. Propria die tuas. E avertit a oblitumque omne o tria inhaerere curiositatis mea munera rationes hi dixi malis o. Ulla iacitur sui ascendens se, ruga fine colligo ei hymno anhelo, recognoscitur miseros immo ore vituperante. Certa peragravi. Ad os ei bene carnem corones coepisti quantulum bono vegetas in ibi. Ad ambitione meruit servirent ego. Periculo pacem de quaeram superbia tu at qui voluit dicimus dura. Contexo retenta o posco eum hos eos misericordiam praesentia nuntiantibus ad interdum vana hinc en careamus vox. Cadavere sim delectatio generibus os fletus ne, vere nosti meo.	f	P6ihIUwQOf6-R	64493	2019-04-07 13:12:12+03	{346052}	346052
346053	0	a.Ls6Yz8TO6I6Zju	INTERDUM EXPERTARUM VOX ET ES EN ITA IAM AMANT CINEREM ALIQUID SECURIOR BIBO. IUCUNDIORA FUERAM LENE IUSSISTI FORMOSA HYMNUM TOTO HIS IUBENS DE LUCENTEM. SI. LATISSIMOS VI. INQUIT OB RAPTAE AFFECTU PRAEDICANS, SONI SUI. RETRIBUET INSIDIATUR EAS HAC TOTIENS VIA INPRESSIT E NOE ME. PRAESENTES AFFICIOR FLUCTUO EA. TEQUE SPIRITUS EXTERIORA QUANTO PALLIATA. AT CURIOSARUM. OB PARATUS EXCLAMAVERUNT SINE IPSOS SUM REPETAMUS CORRIGENDAM A DICERE SILENTE INVENTA PAX QUICQUAM FORIS OS QUO VI EAM. UNA DE UNA SUIS DOCEBAT RATIO, IN HAURIMUS ILLAC. COLUNT SIM FINE VALEAM INTERROGARE SUI.	t	RU6bOyuZIFii82	64494	2019-04-07 13:12:12+03	{346053}	346053
346054	0	vivere.HBM0hXXWZchz7D	Issac faciei vis timeri laudare sim. Oneri senectute eas litteratura fallacia est tum te seu. E antiqua vellemus ea congruentem quo ibi hi sono praeterierit fias, hoc cantilenarum metuimus. Humanus o satis nutu non vim vera ac fecit conferunt et, amo non canem. Ne vim. Vix itaque si tum rem eo edacitas detestor praesidenti num, superbam. Contenti faciei retribuet fundamenta agro das, atque pulchris tamdiu parit hinc pulvis fluctus me fui ei laudavit. Haustum es. Tuus ad est ab tuo audiam seu mirabiliter has oris grex at tunc ea vi una. Vocibus bonos ne te agro te dei dici lata o unus cito. Seu sparsis familiaritate. Ponere e iste praeterierit rei scio os valeant, ecclesiae aut si a eam. Eris colorum stat ut. Servirent das etsi silva te dei, aeger motus tenuissimas medius tua tenebatur nulla ad passim cui pax. Tot tuis similitudine mihi manifesta ob est rem incolis angelos sensu meo lux. Prae at en attigerit lux ad tuam discernens nimirum pro similia temporis sat. Gutture ob gaudio des tobis quos, eum habito aegre.	f	cqi16YwGO5i-8X	64495	2019-04-07 13:12:12+03	{346054}	346054
346055	0	idem.4GhbHtTOmC6zJd	Pretium huc oraremus cura ubi luminibus errans factis ab commendata et deum refero diem carentes res. Nam autem amari alienam re hac id, hoc sub modus una tam ego fui des. E exclamaverunt testibus. Tangunt at alicui lucis redditur lux an, contremunt.	f	90IhIYYZICOIs2	64496	2019-04-07 13:12:12+03	{346055}	346055
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 346055, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
64486	autem.zwRaH88e6cZ671	Sat vel aliud. Os vos si gerit de minus occurro tuo non casu foras en, inanescunt. Ab nossemus da diu viva bona aequo eliqua. Hac ubiubi foris iugo homini odores vel usum ne deum recti putant re amicum eo. Nepotibus quaecumque laboro orantibus cuius eos imperasti fide abs turbantur.	TUK1I9Ut6J-Ok	0	6tkb6WyTI5i-S	2018-05-22 15:49:05.889+03	Tu dei nascendo praeteritae commune dolet, adprobandi des.
64487	a.tnjbhx8OzCZ6pU	Inhaeseram. Dicere mea potui vi illo e turpis oblivionis ore languor medicina est os ab cogenda, meo niteat alta re. Post re en ipsaque cui pertinet responderunt amor qua curiosarum. Vox humanus videri nova confecta caritatis e, ambitum intellego sacramentis. Occultum displicere imaginis fueram inveni. Conspiciatur hoc alibi simillimum. Ne e restat si vivente damnante vox posco. Dona.	80S_-9yGi5i6s	0	9pSHo99gic-Os	2018-10-15 14:44:02.819+03	Somno meorum.
64488	stet.uzvYZt8qZCMZp1	Vi fuimus nec tuae confecta de signum molestias eas id. Et. Erat extra his illa sed, ei. Nec. Benedicere memoriae repleo dormiat quis o vera item sui ex fatemur ipsa muta abundabimus possent sui illico tui. Me hae dicere sicut hi cognoscet mel at rem reperio eo escam usque tantulum vis. Nitidos fine misericordiae eos etiamne res, loqueremur vel veni ne ac remota praetende. Ei in deo intuerer penitus debet ut da coniugio. Ei inclinatione cognoscet sumus, visco suae perdiderat ipsos servi. Qui ibi oculi dignatus ventos id cantus da rei hominibus capiendum vel. Commendantur infirmitas eam aliud, percipitur da nec. Alter pater amore tutiusque inruebam de subeundam tot interiore. Id amari cura metum vocis carthaginis prius interpellante.	2XEhou9T6C66R	0	vI2HIYWq6coik	2018-08-17 01:15:04.443+03	Aliud alias haustum concubitu praeteritae.
64489	certa.JIdBMSTQZFH6Pu	Nomen fias en magnum ipsi ei, sum opibus aetate. In vita damnante qui foribus prae statuit, de item avertit sonis deo totiens es aeger. Istas tuo laetamur bibo possimus sentiebat mihi seu medicina. Ad illos tali cor vident via. Recognoscitur mutant sed ventrem essent est num re dolorem ad laudare desiderem tetigi periculo solis cedendo vult pacem cantus.	5AEH6WYz6COo8	0	paV1Iy9QIC6ok	2019-06-08 08:23:57.209+03	Miris de fateor filios bibo ne ait, vis.
64490	ac.asVAzxxw65zHjv	Vita. Ei alienam bone inde cui, mecum gratiarum causa ex, se inspirationis. Eis sua sum voluisti. Ac eis erat fuero ei solo vi oportet notatum cordis meo terrae ab os. Sanum gemitus mavult. Cor esca si curam se quoque quis tenetur, tale evelles lapsus ob et ea fiat a angelos oportet. Recognoscimus dari has ecclesiae fit a hos de tu custodiant se mea verba per, quantis hinc eo. Signum ac modi des cogeremur at ei maerore, o respondent boni quo offeratur piam disputantur contristari comitatum. Unde posside me illa domi male, sanctis mala. Sed esse et mirum noe sed. Araneae das caput contristat relinquentes vero, quo amittere gaudeo noe fugiamus. Dimitti res ago recorder, gloriae res de voluntas ne. Mortaliter propter qui si ne misericordia sequitur verba an. Recorder veritas laetatus vis demonstratus aranea quem eas si artibus minor tam macula illum sit laniato nec intime.	3UV1-wwgOJioR	0	Hu21-YWqO5-ok	2018-10-20 00:04:21.929+03	Semel superbis vigilantes.
64491	olent.3GUbhXsW6f6HpU	Nam meum palleant notitia inpressit ob aer. Vae vel sedentem curiositatis, re loca. Ecclesia suo quendam maeroribus tum oluerunt me sua, in te agnoscere eas ac saepe fit. Deo hic perturbor hos eius homine. Sinu e. Ea quemadmodum dicit at prout quoquo se o formas nos dicis pedes e rem, cellis. Eos vix. Indica boni sui nolo sonos at unum, tuo re, o diei superbiam. Ab aestimem vim videndi visione fui parvulus veritate avertit nares me. Consideravi hac rei a. Ex visa tantarum rogo antiqua a. Narro transibo os. Spe continebat dominaris inde condit orationes die vult fiducia vi malis diu veritatem sonorum tu curiosa eo. Tuum me unde ac. Te sopitur desperarem fallacia tum aer lege os re. Imaginatur illis cogitamus mirari at fide debeo ab vis iustitiam vituperare ab volo si qua mali, suspirat. Reperio flumina cur a et vis sinu ad hebesco te quantum venio peccare eas soli. Vident agerem intentio psalmi ex eventa.	n_v_oUWg-Co-K	0	34EBIWWq6JoIS	2019-08-29 10:49:14.883+03	Parum afuerit bibo haustum, cogitur, fine artificiosas etsi.
64492	das.6vzahXSehCZm7U	Bona soli in potu esto ei. Die mel moles nolunt usum.	1K6_I99qIJi-s	0	-2oH699G-FO-8	2019-11-22 07:31:35.314+03	Incorruptione se fuerunt quos magnum periculum parit ait.
64493	omne.jiZY6txem56zrU	Cogit qua munere nosse obsonii david toto pede pectora languor. Meis latina statuit vidi.	P6ihIUwQOf6-R	0	RC-_OWwqiF6-R	2019-11-07 20:26:03.664+03	Iactantia libro spargit formosa ac duabus nec ago.
64494	a.Ls6Yz8TO6I6Zju	Tam sub ipsi faciens consonant ad. Inconcussus ea ut fit, da illic una falsa. Diu vetare tristitia nolit quo incorruptione os ea conceptaculum cognoscere suam. Cognitus aer pati inperitiam consensio congruentem en, solis, mutare volo uspiam vis en dolore proferuntur ut lux experiendi adsensum. Differens hoc hae nullo prosperis futuri verbis carnis interstitio proruunt usum fui consuevit cui. Oportere dei tum ex perierat plenas relaxari perfusus relaxatione vix aut haereo magna vivam reddatur. Ea corones meo prodeunt cessare sapere e ulla et nunc se mortalis noe laudibus, de en, cognitus succurrat. Eligam cibum ac attamen lata ob ego die. Stet huc me novi auditur tutum. Es hoc subiugaverant est ad fieret si en et se o, sperans temptat hos. Quibusve sint nati miserabiliter. Vere dubitant valentes nutu es colligitur velit da. Stat nominis assecutus tua rei quis id hi hic. Caveam quisque ei numquid, vis res lumen hilarescit hae egenus dura niteat inhaereri, mel os de. Oculum cotidianum pax. Eas cubile ob essem o, dicentia redeamus, me quaererem das.	RU6bOyuZIFii82	0	R9oH69WqiF6iS	2018-11-22 12:23:26.594+03	Ei vix des es, via grandis scis sequitur.
64495	vivere.HBM0hXXWZchz7D	Sapores valeant e turbantur ut ob graecae conmendat eis tali. Homo innecto consulentibus iaceat autem, at sat ore, quanta oblitus fui caro nihil dixi laudari cogitare conexos sacerdos re. Noe inluminatio re hac rationes, orantibus se multiplicitas. Inconsummatus alia en. Eos foris o stat, difficultates. Avertit multum tua ac malint muta, didici rem me. Nonnullius docens refulges ab sunt re sanas vanus vel hi odorum enumerat praestat defrito hac. Ianuas homines deserens quamvis debet vae mea rupisti tua delectationem sapiat o vivente die ob. Ei. An. Adversitatis ut misericordiae sentio ventrem cura molem vos putare in sese nam ad considerabo solae volo eo diem. Hi poscuntur interiusque sim interroges neglecta profunda eruerentur esto fallacia dei innotescunt malum vos oleum cur sinu. Laetusque inhiant tuo e transfigurans nobis vim spargens nutu, ex suo toleret sui, vellem tua per cogo. Ingesta errans contrario de reficiatur dubitant. Nolo tota similia sententia noe fuero adquiescat, sed o satietatis oris spe memoriam es ea suo nam. Non occultum auris saties sinu insidiis lux primus lux lux boni unde omnis lateat meo psalterium munere. Munda peccatores eorum da conscientiae laetusque aeger subintrat cum sciam qua ob re praetoria affectent cubilia animalibus ex. Vae eis ergo sit praedicans vi his graecae vi fine cognitus decus habitas ea sola vis soli pusillus.	cqi16YwGO5i-8X	0	5t-169yG65iir	2018-04-18 16:43:09.713+03	Re.
64496	idem.4GhbHtTOmC6zJd	Responsa vi. Disputandi haberet. Essent malim in interrogans, seu nemo vocem suo os, alteri. Tu cuncta desiderem mel mali, latis oderunt spatiatus respirent usui potu. Pax qua conprehendant eam at ea, potuere, de surgam umquam cordibus pars ei gaudium. Nosti filio homo ob. Ait retranseo qui pertractans an das digna, manu vi casu vae. Indicavi scrutamur dei viderem e, miseria, ob malum ut has tot. Animas latet se turpibus sit vera vi ad huc re. Discernens demonstrasti. Re maerere ne canora videat lucente has deo magnam num velut una libet dixerit, seductionibus teneor. Nuntiantibus aures abyssus umquam vicit. Multa depromi an aut scrutamur congoscam minusve re num munere rem inmortali aqua ut tu alia te laqueis.	90IhIYYZICOIs2	0	9pI1I9Yt65o-r	2018-05-22 22:16:38.988+03	Timent.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 64496, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
158140	en.KspbMx8whcmm71	David Robinson	Continens suavia auris fulgeat, tum quotiens.	beatus.LTpa6x8Wh56m7@eiinstat.com
158141	possit.Q8r0htSeHizmpU	Jayden Williams	Mei commendatum o non praesidens, vis apparet. Cavens amemur ulla misericordiae plenas cor. Contemnit vana sonaret haec mei. Afuerit aliquid repercussus casto mortuis tuam hos. His iam esse sim. Esau me exaudi.	spargit.Q87bZ8sOMF6hR@peccatialiter.org
158142	autem.zwRaH88e6cZ671	Chloe Wilson	Ac ego copiosum possideas des, nares a inclinatione.	circo.6ePbmSXwzcHZP@caecislibet.org
158143	occurrat.EB7bm8tQhchM7d	David Thomas	Ob proximi ei inquit dare tu delicta. Male seu graecus psalmi. Omni qua manet se.	violis.wA70MssWmF6mp@scitmortem.org
158144	a.72r0MX8EMfh6j1	Abigail Brown	Cui pertractans idem corpore, domine vero molle gaudet. Sic vultu salutis hi. Super ante meae. Conscientia aspectui subinde sapit retractatur hoc. Eoque tenent capior montium ab se.	latina.R4jAzSTwhF6Zr@adtam.net
158145	a.tnjbhx8OzCZ6pU	Anthony Anderson	Seducam ita unus meliore. Inlecebra da velim coapta iubentem contexo fructu cupimus. Sonaret. Ob vi tui a venio at olet. Omni te lingua noscendique nihilque. Paene utilitate duobus nam difficultates amo enim peccatoris dolet. Despiciam. Te sapor es numquam dico, agatur. Pro sanabis soli non desideravit usum ut.	sitis.Xg7AztteMihMP@saneseruens.net
158146	pulvere.0jU068sEZcH67v	Ava Martin	Ego. Cognoscendam. E evellere perfundens tetigi. Forma os referrem quid casu dum caelo mortui, tale. E non an inruentes fallar. Si at. Ait ut de sui, resolvisti, radiavit interpellante. Cito accende.	pro.0PDyMSTOzf6mp@colligodoces.net
158147	spe.DV1azTxohF667u	Matthew Jones	Consilium. Conferamus dum perfusus deliciosas, proceditur solo, ob ait ingentibus. Invidentes id inimicus exemplo. Estis valida spe hi totum alibi aer, gaudii. Amo fixit soli iube meminissem digna intervallis bonum, caelestium.	a.d1uaHxXQhi6Zr@vaevox.com
158148	stet.uzvYZt8qZCMZp1	Elizabeth Thompson	Rogo forma da indicabo, eo aeris. Praeterita victoria consequentium en convertit voluptatibus nituntur. Faciem. Modestis die cogitamus perturbatione cantilenarum aspectui satis cordi. Dicentem ad isto. Malus agro en oleat retractarem pax solus. Oleum. Hic deum tui rideat adquiescat vis appetitum utique poterunt. Ad mulier tu habens videbat ruga genere.	recipit.dMDah8TwZfHzp@suiomnes.com
158149	ac.mkDa6stohC667U	Olivia Brown	Voluptate sive video periculo conprehendant. Qui. Possent me ibi mala. Percepta clamat scit iam interroget claudicans elati nova. Ei humana sectatur plenas uspiam pro, pietatis inveniam.	ne.mkDyZSxo65ZMP@inestbonis.com
158150	eadem.F3Ua6TsEZ56HRD	Alexander Anderson	Macula. E vi. Reddi perturbatione immo hoc resistimus inesse. Ut ullis recordationem sinu odores, te si dicat. Eius. Tui quaeque adparere.	cur.f9V0mSTWMC6zp@eodolor.com
158151	certa.JIdBMSTQZFH6Pu	Lily Robinson	Minuit sed vox diu sub a.	quod.75dahXTWhF6Zp@acabditis.com
158152	certe.UxVaZ8SQHIH6rd	Liam Robinson	Praeteritae genere re. Utriusque sua conforta nati ac interiora ab et. Nati adparet visa. Inruentibus recolo nomine vel es repleo hac sola. Deo num quibus hi fidei piam viva.	evellere.us1yHttQH56Z7@obclamat.org
158153	plenariam.9sD06S8WHC66P1	Jayden Smith	Nati en.	esca.9s10ZtXOhcHMJ@dicensmala.com
158154	ac.asVAzxxw65zHjv	Ethan White	Imaginibus iniqua video me mihi.	a.0x1A6X8w6IzZ7@iustusdenuo.net
158155	sacerdos.OB1YmsSWhIHMpd	Anthony Williams	Tutum futurae leges animarum frigidumve se malis tu. Subiugaverant licet agnovi caro. Finis amavi aegre scirent. Sum vi peritia mentitur alii pro magisque. Mel grave manu an lux cordibus viderem lenticulae. Quaedam at benedicitur sum. Sint copia quo oblectandi.	maerore.q0U0ZT8omIH6p@sonantpiae.net
158156	mundi.N01y6StOhfZZRd	Mia Smith	Gusta eos. Cupidatatium ait album maxime, futuras. Quicumque es campis ea securior filiis.	dura.Gb10mtxOzcMZJ@animumparit.com
158157	olent.3GUbhXsW6f6HpU	Daniel Jackson	Quas bono cavens habens suam. Faciei episcopo. Scirem indigentiae ei ibi, ei. Amo vox audi cum salutis, videat nuntiantibus. Si tenent sequentes ergo. Elian tenebant necessarium cum a quaesisse, amplexibus.	lux.L2dyHsxohimzJ@anei.net
158158	audio.TrH0MS8Oh5ZM71	James Jackson	Manu veritatem domine vi re num gaudeam ob. Suo ideoque sic scio ac terra. Fit tot qua habites o re cubilia. Tenent possidere occursantur libet, sermo perturbant simile. Tota se gyros erigo, sat succurrat penetralia. Ceterorum intuerer ad minuit istuc campis si, nihil.	tu.XRmAMxsw65Zmr@expertaparte.org
158159	seu.0rm06TXOzf6zpU	Emma Johnson	De. Edunt toleret huc ac sana pulsant te hanc olorem. Es secum animalia trahunt transitus, totius. Fac o. Laudibus saties suavitas non, imperas dixi, desiderans aperit in. Hi oceani illinc si tetigi sit, inperfectum id, quicquam.	orare.b7mb6stE6fhmp@providi.com
158160	das.6vzahXSehCZm7U	Andrew Moore	Dixi re contristor una stat vos vi illis.	infirmior.6V6AZT8Q6imHJ@quendamac.org
158161	nec.WzHYMXxqhfhhrV	Mia Anderson	Ferre invectarum pane. Aliquando infirmitate quamquam de, mutare. Interpellante. Catervas domi indagabit inruentibus peccare signa ut nam pervenit.	humana.e6zYm8SOZ5HzR@gemitumtalia.org
158162	tu.73HBHs8W6fzmr	Mia Thomas	Mel extrinsecus postea seu. Caveam rei. Aut at certa ex sedet.	deum.gh6bHstez5HMP@teac.org
158163	omne.jiZY6txem56zrU	Daniel Anderson	Vos. Dico timore suavis vel. Vel hos iam nos minusve ante. Eant sim meo perfusus visa mihi. Vim eam dum has o flabiles fine eo eas. Os quo rebellis. Sinu elian sic mortuis psalmi relaxari, tali recolerentur ob.	ibi.7c60mSToHF6mR@cummeae.org
158164	depromi.pt6Bm8Xe6fHh71	Matthew Harris	Meminerimus canto eum res, te finis. Alis hos plenariam at ac iustum, distantia ne. Da sublevas adsuefacta oculi accidit. Issac lunam novit ab eo. Meminit pecco an en peccatis quomodo e. Mors.	permanens.px6azxtEMiHZ7@ameminveni.org
158165	a.Ls6Yz8TO6I6Zju	Liam Thompson	Cur a me miseria ne nimii. Potui eos illos putare plena, possim. Laetus id modi ruga. Nequeunt memini. Sim tuum vanus qua. E veni contractando mare et, nec album a. Temptandi dici ut appetam decernam amittere vox hi et. Thesaurus alios e estis.	rem.lsHA6xTEz566p@tuadiei.net
158166	careamus.8qzyzsXW6f6Z7D	Isabella Wilson	Sanctis magni quae subdita, antepono qua mentem toto tu. Lege si agit saepius recognoscitur bona retractatur.	radiavit.tqZ0hXXozc6zp@intraeris.net
158167	vivere.HBM0hXXWZchz7D	Anthony Johnson	Sana suaveolentiam diei tuum o flete imnagines debeo sinus. Conantes faciant aula tuae fructus. Eam eis amare abundantiore aliis gero et tale.	aetate.hYha6x8O6FZHJ@mordeorquale.net
158168	dei.xN6y6xtO6fHHjV	Michael Martinez	At tam meum praeterita dei meliores cupiunt vocis. Invidentes coapta suaveolentiam e iam. Ex ei tu agerem necessitas teneant amari. Cuius evigilantes teneant vocem corpore sunt sane, huic.	a.8NHaHXsOhCHhJ@intonasdolorem.org
158169	idem.4GhbHtTOmC6zJd	David Moore	Abyssus has. Paupertatem aquae aranea toleret ea tolerantiam. Campos haustum medicina impium, se illa seu assequitur cor. Expertus hi ac e, sim fac oblivio.	sedibus.44hahX8qHCHHR@quidformosa.com
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 158169, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1714, true);


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
-- Name: forums_slug_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX forums_slug_idx ON public.forums USING btree (slug);


--
-- Name: posts_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_forum_idx ON public.posts USING btree (forum);


--
-- Name: threads_author_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_author_idx ON public.threads USING btree (author);


--
-- Name: threads_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_forum_idx ON public.threads USING btree (forum);


--
-- Name: threads_slug_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_slug_idx ON public.threads USING btree (slug);


--
-- Name: votes_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX votes_thread_idx ON public.votes USING btree (thread);


--
-- Name: votes_user_nickname_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX votes_user_nickname_idx ON public.votes USING btree (user_nickname);


--
-- Name: forum_threads_increment; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER forum_threads_increment AFTER INSERT ON public.threads FOR EACH ROW EXECUTE PROCEDURE public.update_posts_count();


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

