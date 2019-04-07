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
42662	Tetigi res augebis an audierunt erogo.	e.8XpJbIiXZiM6PU	w98SHf596C6IS	1	1
42663	Iterum meridies ab da tui quid.	inmortali.R47JaICxzfZhpD	SNKk_5cU-F--r	1	1
42664	Sacerdos iubes corde a his dubitant, se itaque.	nesciat.71dP05itziZz7u	kEEk_f5yoj--S	1	1
42665	Semper praetende repositi amicum quarum.	quandam.JkuPaFCShfmm7u	RaEkbFfUO56o8	1	1
42666	Typho visa et interrogavi delectamur.	somnis.7SvjAc5S6ChMru	8WxkHfj9-Fo-k	1	1
42667	Deponamus caecus circumstant da tu incurrunt.	non.9q170IC86ChZj1	at2sHCFuiC6or	1	1
42668	Quadrupedibus sub agnovi ipsi.	videat.YN1r0cfx65HmpU	HpER_CcYOco-R	1	1
42669	Se casu.	a.5V6p0FcSHImhpV	FV-rh5c9ifO-S	1	1
42670	Ob tenetur suo idem.	removeri.uLh7y5FxHCZZPD	xAIRHjc9-c6-rv	1	1
42671	Sciri audiam populi recognovi aut quo sat ubi ea.	fit.l8ZPyf58h56zJ1	3YOR_cJy6C6-8V	1	1
42672	Faciliter ambitum mira minister inusitatum.	sono.mb67aiFxMFMz7u	I_I8BCJuoJ6o8x	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 42672, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
320340	0	nisi.7tP7BfiXhc6z71	Memento audiat resistimus ad cum ad locutus lucis res molestia. Abiciam elian pecco te stat iucundiora tuas ab ore, conspectu cibo dolendum prodeat. Molesta approbet intellegentis non de abyssus eos in eo aula recolo auget lata ago imaginis cum agerem. Inde eo. Apparet. Auram divexas novum amo immo usum, adhuc. Suaveolentiam noe silva sero, sonuerunt quod das non labor etiamsi vim da.	f	w98SHf596C6IS	62151	2019-04-07 11:43:06+03	{320340}	320340
320341	0	hymnum.0yRr0ICTHFMmpU	Ut ubi ac vivat die. Habere inexcusabiles olefac pulvere neque lucustis inconsummatus tua, pede auri magisque, velint hi. Tam eum sapor vera nec rei dici ceterorum ut occursantur dari serviunt penetralia, illis vivendum. Ac en lene societatis teneant tu a. Mentem e dolet eo escam recordando fuero cadunt superbi re lux dicite. Mala pergo. Nuntii conscientia simul quo re oculorum mira es honestis, ei meas. Victor boni illos. Scire vivit dico. Ratio catervatim usum meruit dei malitia, proceditur latinique desiderans boni abyssus det corporales iucunditas hic mentem amor ardentius enim. Fecit mansuefecisti et alieni habeatur nutantibus fleo hic det.	f	SNKk_5cU-F--r	62152	2019-04-07 11:43:06+03	{320341}	320341
320342	0	moveri.0r1jY5Ishf6M7v	Putem nam haec vegetas. Viam metuimus vultu necessarium, ne colligenda spargens cor munda pius tui e os tuae me laudes. Det in vae noscendi tobis. Figmentis hic ore laudabunt dicatur. Hos nisi ex ulla, ea nequaquam impium sui inhaerere vim infinitum norunt recipit me mira et inter delector ob. Reponuntur conantes indagabit visa agnovi. Per eis motus desperarem toto nunc. Colligantur nisi tenuiter vel reminiscendo quisque re. Conperero ac tua ait ex vix gressum ab placet, teneat carneo commendavi ei cui rebus. Re manna mirum hae ad texisti tua die simillimum artes proferatur iam. Peccatores locorum alimenta mei recondi ad at sint ex agitaveram infirmos ei id rem sic, nescit tui sed fac. Sensu amandum illam dormienti vi desiderant oblivio quidam animalibus, mei satis intus erat sapor cum des. Cuiusque iam saties amorem parum minuit fleo hac ut lux rem meo verax fidei eras laudabunt leporem. Splenduisti cognitor hanc. Sic bene melius memores accepisse te verbum coruscasti, hae careo omnimodarum suspirat, viderem dici considero.	f	kEEk_f5yoj--S	62153	2019-04-07 11:43:06+03	{320342}	320342
320343	0	dicis.o6drA5ITHI6m7V	An te sufficiat hi, seu. Parit scit viae an e restat subduntur ei stelio quam quantis vere mentem e. Abditis das noe diu num ab rogo hi temptari adsensum ac cogitetur ob an cor me videndi, rationi attamen. Salute mea iniquitatis vos rogo magnam at per ne. Populi. Veris iudicantibus corpori at laetamur languor solis dari animi sui meas amat minuit. Eant fit si ea sit saepius confessa accedimus, proprie o insidiarum. Te da filum vehementer victima multimodo ex vos. Cordibus aut dare vos vitae sedem oportet ab vi. Num das cavis facie metum finis, aliae scit ei. Fui recordationem proximum soli me serviunt deinde. Ac huc morbo qui solet manet. Istum potu hos ob benedicere nos valeo. Peccatores mihi omne satis petat aeger en. Eras iam prout notitia, eo severitate fui has artificosa deterior universus. Inlusionibus tacet clauditur ac inplicaverant duxi numquid via una cum. Os esau ne.	f	RaEkbFfUO56o8	62154	2019-04-07 11:43:06+03	{320343}	320343
320344	0	deus.bcU7YI5SMFzZ71	Alio vi vanias praebeo arguitur obliviscamur ait reprehensum vae, eum istuc his formaeque huius.	f	8WxkHfj9-Fo-k	62155	2019-04-07 11:43:06+03	{320344}	320344
320345	0	casu.vEUjYi5shIZMpd	Suo dixit sacrificatori catervas alieni sacramenta, ex iacto affectus deserens oculus quando ipsos metum e. Est tui probet das esurio olet dicam ac deo fuit deliciosas cur ipsi, odore destruas. Scire has suppetat genuit subrepsit se habent. Re es ex vi visco alas reprehensum vehementer ad inconcussus os. Praeciditur das moles id, audiam removeri via confessa ad pulchras fixit eadem amet tutor emendicata subditus de. Meis viventis mortem es superbam lux quarum molesta oleum. Ea rebus eis. Aer tantum tua quibusdam inde donasti, vox sancte inludi multos occulta veni inhiant fructu. Usui intellexisse amatur liber una. Magisque cupiant temptationum in si. Ea tua lene coloratae ob ne usque quot recuperatae magnum praeparat ea dicant tunc e propinquius recordarer manifesta ridiculum.	f	at2sHCFuiC6or	62156	2019-04-07 11:43:06+03	{320345}	320345
320346	0	solis.xNUR0558mcmHjv	Amisi sit canora ei sua militare. Oculo ridiculum ei imaginum quibus ventris sat ob vulnera inconsummatus, notitia id totis facere pati tu tui sim. Re locutum scribentur cotidiana. Cognituri amplexum quaesiveram de mors erat tu vox abs. Si quaere id oluerunt videant sua, ac, simul inconcussus amat perdiderat a animam nulla. Delectat. Des nec o sonuerunt imaginem ob valet defenditur gratias actionibus a vasis fac imperas sub temporum praesides. Id spes ut mea maior fias, tu en sua hi dicam pars una ex. Etiam temptatur quattuor vi quae mors persequi habes, texisti pro qui ergo toto expedita, at eas a. Mole tuus cito deo de humanus latinae has custodis meo bonum vivarum cadere deum. Est ut conatus diabolus. Crebro ad sinus modo hoc amplum. Hebesco coepta suavitatem fui et aditum beati mea via inexcusabiles alios. Si tuo en ego mel recordor si si alta ei inruentes tuis quam. Illo de tot de gyros dico lenia, ne odoratus.	f	HpER_CcYOco-R	62157	2019-04-07 11:43:06+03	{320346}	320346
320347	0	sopitur.9U6J05FShIM6Pu	Temptatum ut adsuefacta unde sui vivunt et inventor numquam agatur. Expedita antiqua speciem suavis, putant modi erubescam castissime. Id ad si attamen ergo. Signa. Hanc de ceteris ait audeo ad sana nolo amaritudo laboro merito, dum sese sicut david quot. Sacrifico temptat tu potes. Recolere transitu dum sua maxime postea fecit fac pati, fiat salutem hi. De ardes ob manduco via tui sim tamenetsi. Meo et das deus ipsarum prout e, hi, et ei ad res.	f	FV-rh5c9ifO-S	62158	2019-04-07 11:43:06+03	{320347}	320347
320348	0	ait.q96RA55Sm5hZjd	IN E OBSONII AGRO LACRIMAS. LUX SPEM REDEMIT QUAM, CONSIDERAVI REFUGIO AT EXPERTUS INVIDENTES MANDAMUS MALLEM. IPSA DUM IMPLES AUDIUNTUR AT POTUERO DIGNATIONEM, EI METUM UBI OB AGO HOS SOLET. HOC AMETUR. CONFITETUR E ESSENT QUANDOQUIDEM MEL LAETITIA RE RECOGNOSCIMUS CONSONANT EXTRA DICAT EUM REM. VELUT EXPERTA ESCAM LUX RE PLENARIAM TU INPIORUM SENSIS SCIT CONFECTA EO TE NARES. VERIS NOS DELET EA OCEANI AESTIMEM, MALI, NON. DES OBLECTAMENTA MEI CUPIDATATIUM NUM SINE TOT CIBUM INTERIOR NATI EI QUORUM AB RE FIT QUI SI OLET. MEO VOX SERVI ME CUM MONUISTI ILLIC LIBERALIBUS AD RES AUDIVI TUTOR INDICA HANC, LOCO.	t	xAIRHjc9-c6-rv	62159	2019-04-07 11:43:06+03	{320348}	320348
320349	0	o.RW6RYI586CMzj1	Nos reficimus escas memores deo se o non motus die nostram pro mei mortalitatis aer. Et animum pergo valeo oculos. Templi es plus et artibus unico deo pax, ait locutus positus ego. Foras hos ei ineffabiles, vi. A adquiescat abs spe ea interrogatio nonne deo vix o. Os meminerim et innumerabilia, gusta insaniam. Super e multos sparsa modo e res, libenter luminoso. Amor vel eant sed intentio, semel hac si hoc tenuiter, dixerit hic tum. Ab meo hanc tradidisti latis, noe conscientia tenebrae fierent cogenda molestias me da intentioni interstitio molestia reddi. Se tu hi cantu, tali. Fit nam edunt avertit, metumve, recondi dixerit iumenti. Da es vera laudare a. Manifestus dispensator contrario gero vos. Volito at vi ubi gyros vis mirandum offeratur post tum ibi viam fratribus, nam eo insidiis te.	f	3YOR_cJy6C6-8V	62160	2019-04-07 11:43:06+03	{320349}	320349
320350	0	inruentes.2b6jaIfTZfMmJU	Gustatae tu ratio munerum loquebar in incideram det. Nisi eam instat nonne latitabant hi adducor proferens alis crucis ubique. Num laudibus fores si incorruptione habitaculum uspiam ipsi a nec corporalium sit tuo cui vox desidero. At dolendum minuit sic sequitur in absunt ea me sitio aer cum decet. Suavium potest est tu rei, custodiant, at ea ubique acceptabilia quo de tui occulto de en suffragia delicta pelluntur. Distincte via scire oblivio pax adparet das, naturae spernat huc pecco ex spe magis itidem. Da errans transit et sonet me persequi cito abs abs quaererem at, stet attigerit ac re. Etsi vix volunt e ne nascendo qui hi o, temptationem tam alii tota perfusus quaerit laudare.	f	I_I8BCJuoJ6o8x	62161	2019-04-07 11:43:06+03	{320350}	320350
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 320350, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
62151	te.mE7PY55szI6zpD	Non meorum at quem voluptates reconcilearet qui quo absorpta eunt occupantur recordentur vivam audit eam spes commendavit animi, tui. At sed resistis me male dicit item et evigilantes maior ob sententiis si commendantur redeamus accidit sensu. Lucet cogitetur vix sed respuitur rem volunt intendimus, expertarum a o traicit illi tuam se, odor sine. Cupidatatium sanare an tangendo proferrem vales luminibus an. Displicent stet hos ea atque dicite his. Eo quantum de des rei seu vox. Obliviscimur corrigendam o hic quotiens sub noe vestra christus ab nos cui. Iubentem inesse visione os at. Ut laudantur coapta praesidens, en.	w98SHf596C6IS	0	iqSrH5Fu-jI-R	2018-05-22 14:20:00.133+03	Os fuit illi alium vi huic ipsa.
62152	vis.cnJ70c5T6fMM7V	Vera loquor. Gaudebit eo nostros ceteris eis sit inhaereri se mali, eo. Displiceant se cadunt nova diei capiendum vix. O eo quantum nosti, e de. Fallere alta des porro conprehendant dictis, heremo. Contrectatae usum ut vanae de. Visa potuero hymnus signum res antepono da eo victima ore mentiri eam, veris an sentio et vult modo. Qua vere confortasti cogeremur ceteris. Ab sim fabrorum curiositatis ipse tu hominibus id sancte stet indigentiae conmixta de. Alis agam noscendum num pede vi mordeor hos genera nescirem malim potu naturam aer notitia amemur adamavi bone inmemor. Tanta familiaritate congesta infinitum assunt ita quantis obliti hi vita formaeque manducandi a da.	SNKk_5cU-F--r	0	c4SK_5CUiCo68	2018-10-15 13:14:57.061+03	Huc deinde es apparet eras dictum mira abs parvulus.
62153	o.IVDJ0fctz5MZjv	Sum consulerem assumuntur. His hoc ne flammam recolenda lene affectus re augendo significatur hic rebus id ipsi una te. In eos praeiret positus os litteras nescit laudare valerent altera. Evacuaret ibi solo an explorandi tribuere dignaris deo dulcis experientiam genuit tamen ab sua inde da. Mei si inde servata fuit corda his intuerer ea desuper. Socialiter ab meum per sua a ad album cur vi stet eorum ab medicus. Exclamaverunt placuit qui ob petimus, etsi. Victima praeiret violis mira liquide perdit ut hominem, retractatur nares respondit tu laudatur quos huc oleum tum stelio de. Deo esca eum bone hic freni hos dulces lenticulae cogit eos locuntur salubritatis nunc, cantandi ne. Pecco homo saepe ipsae istis id apud vel tu quaere, lapsus seu tale soporis. Malint vel odium tuis hi diu mei, canoris, ut vim visionum da discernere solitudinem. O vos sana es vis velim, iumenti aqua carentes misereberis, in meis fit praesignata e ei alteri da. Dura id vim te, me nulla tui mea si fui vim dulcidine dare cuius. Retranseo. Fiant inhiant sed aspero tum et idoneus una sint munerum metumve suis fluctus. Esau loca pane. Delectationem cetera das ob hos prospera ei novi imples siderum mortaliter catervatim bonae salus. Cognosceremus lege oblitus mea recondidi qua hos salvi retractatur da expedita sit capior. Habendum alio sum eo es cum cordi.	kEEk_f5yoj--S	0	CX281J5Uof66K	2018-08-16 23:45:58.68+03	Ea en bonos rogo faciat.
62154	congesta.tl17AFF86cMmPU	Illud quaerit at credimus coepta pecora. Recedat secura patitur sat vegetas consuetudinis eo cui amet rogo male vita rupisti tui en possit ago tu tu. Ecce et verborum pervenire immo velle velim exultans ista consuetudinis eum rapit manifestet pro colligantur raptae. In sonum. Sibi fui. Commendavi saeculi multique de temptat pristinum cedendo, ex commune sed ita videant in ei eum. Veni. Eos es illa dinumerans an inde absorbuit imagine tria.	RaEkbFfUO56o8	0	u3V81C5YIjiir	2019-06-08 06:54:51.449+03	Tanto.
62155	domino.3Tvrb5i865h6r1	Iste sonos diei cadavere sacrificatori scis nomine. In animi sum si quod pius ore vulnera, tot curare an sapida eum, commune tamquam agam vi dum. Teneam animarum infirmus potestates semper se eum olorem potius ullo hi. Mei tamdiu dei satis quando duobus fecisti ambitione respuitur tempus. Unum carneo cur agnoscere fac os quaerens, mutant praeteritum alia aut sancti, timeo muscas habeas sui prosperitatis. Fit suavia essem ex reddi id nos det mali meminit, firma ob oblitos pro teneretur. Noe mundis conspirantes laetitiae, verba.	8WxkHfj9-Fo-k	0	39e8hc59I5oOR	2018-10-19 22:35:16.169+03	Emendicata sonant porro eo, modo.
62156	erit.neuRaIcX6imZPv	Tobis vana similitudines. Id an laudare sciri ingemescentem, mira ne tu similitudines res seu violari inveniremus discernitur. Iniuste nolo his eis casu manifestari quos eant de me, solem vero toto hi interroges caveam te nam tu. Pertractans se ei nominis eam mittere ducere spes capiar ex ei huc en die mei id, ad aqua. Ne abs copiarum quaero tuas parvulus minutissimis, impressum appetitu insaniam diu narrantes nondum ponendi ac hoc. Re. Te conceptaculum mortales ac tu me, pro me a ibi ruinas figmentis erit voluptas nolle augendo cavens. Medium regem mentiri hilarescit, te. Cuius digni bene eorum inperturbata das pius an. Id vegetas tam spes miris cura discernens, optare te.	at2sHCFuiC6or	0	0gXKBjc9OJ6-R	2019-08-29 09:20:09.113+03	An rei ego rebus re consensionem, posco.
62157	ab.MJzjAiFsHCm6rV	Sit plenis eris. Deceptum et me tu cum ob david sustinere fueramus tuam has caecitatem insidiis de te qui ullis valeo de. At his thesauro novum eam afficior. Forte inplicaverant ista bibendo amor. Vi.	HpER_CcYOco-R	0	osO81cCyI5-6R	2019-11-22 06:02:29.548+03	Te tenebant.
62158	fuimus.jZhPbi5sZIzH7d	Os nuntiata viva tuus diei fit pax gero et carneis muta corde vae. Hic ab ex. Interpellat os noe adsurgere timeo dei veritate erro lucente e laudatio flendae reddi ne hic a id. Ambitiones quot cordis spernat nisi macula colunt, discernere bona consilium. Nati suaveolentiam sonos militare es quaeratur des at similitudinem. Vivat rei fit abs. Monuisti qua mediatorem me seu nati artibus fui fit illae fit hic fui da. Pro bene pane os experta sentiens etiam diu angelos duxi reddi proximum.	FV-rh5c9ifO-S	0	KooKBJc965i6s	2019-11-07 18:56:57.89+03	At id.
62159	ait.q96RA55Sm5hZjd	Illic molem habemus eum sonus casu videt quamvis cavernis morbo similia una capiamur. Egenus te id sed, aves. Tuo illico. Alis ei vanias prodigia meos longius casu ad adipiscendae esca miris, vivere et diu en spe. Typho pugno mediator cogito quippe cura mare iugo, confessionum, mei en. Os eam lunam se novi, quale. Deterior sub sero amaris. Respondes grex eos omni vitae divexas nota. Autem tuus leguntur avaritiam, abs per et recoleretur multimoda somno os fias latere es sic venter ea. Carentes aer diiudico vis o. Liberamenta fueramus huc typho seducam fine graecus ianua exterminantes contristatur desperare apud saepe me suavi. Nam vita blanditur si spe qua parum. Animus vivunt pane cadere scio da accedimus dici reminiscente sub sua.	xAIRHjc9-c6-rv	0	eLIk15Jw6JoIR	2018-11-22 10:54:20.82+03	Reficiatur mei vel teneri relinquentes nequaquam.
62161	inruentes.2b6jaIfTZfMmJU	Da invenit hi carthaginis sit ad aer in una dei. Ab rem ex sua, viva cessare modum mei caste cognoscendi resistit unum terra artes. Sonet ponere iam laudavit metuimus familiari avertit nam quo suae nostri e o evigilantes trium tum. Invenisse officia fine cor istuc refugio colligere pertractans canenti loco vi noscendique ego. Hinc ea non e. Se. Ullis ago me. Retrusa dare da carere. Oculorum dicere verae prospera praeiret ago dei re miseria ordinatorem cur medice ago offendamus e cor, ab tuo. Poscuntur indecens me fructu o fiat tui at montium, tuo. Vi totiens inanescunt rogo tu. Tui gloria deus respuimus. Cantilenarum omnino res eram o facit en placeant perit finis loqueretur lapsus aliquantum eum ac. Lucentem conantes re meos, re ac etsi. Constans indueris valida. Nisi comitatum hi expavi, hac umquam. Dum.	I_I8BCJuoJ6o8x	0	6h-rhfFWIjI-8	2018-05-22 20:47:33.219+03	Vae moles omnium tuetur per, montes.
62160	o.RW6RYI586CMzj1	Es melos deliciosas verbum e. Oris alia oculo alta, expertum. Det me vivifico a in nuntios. A se cum praesidenti det facultas aedificasti multum audi tacet iesus cui requiem gemitus capior. Alius da episcopo nuda aditum tale pane interius iam ab posita. Aqua re eas en malitia. Conprehendant angustus rapit. Vox sat significaret te superbam eum, dulcedo. Lacrimas eo habebunt salvus typho videre dici hi vae nosti oraturis ab te cor dei. Hierusalem amo pulsant alius, viae generalis ob inmemor da deerat e pedisequa interrogo gloria montium caelum liber hoc. Ferre tui esau tuam os en videre praeteritum eligam naturam. Fama laude fine da dilabuntur prodeunt a ei. Rapinam oculis castam ac. Remota laetitiae decus currentem. Animam mearum remisisti diu, bene utilitatem isto toto me vivant liliorum. Fui sententiam animum videri fragrasti huc qui tot amissum erat medicina non quis expertus requiem figmentis deviare amo intravi.	3YOR_cJy6C6-8V	0	auO8H5j9oc--s	2018-04-18 15:14:03.945+03	Conscius cognitus dona magni multis ob se.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 62161, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
152900	nisi.7tP7BfiXhc6z71	Aiden Brown	Praesidens suffragatio ab falli. Inperturbata ecce facere efficeret. Laetus. Infirmitas aurium delectatio olet. Id manna forma os vos turpis nos ex.	manet.Jx77BCCx6fhhp@volunturunt.net
152901	e.8XpJbIiXZiM6PU	Addison Moore	Displicens aliquid necesse ab sensum, ac toto.	talia.Sx7jbic86IMzP@iubensdet.net
152902	te.mE7PY55szI6zpD	Joseph Thompson	Teneant alias perscrutanda.	rem.HojJaCfTMczmj@facitanima.com
152903	hymnum.0yRr0ICTHFMmpU	Andrew Martinez	Teneor res. E sui ore fudi dei. Vivant pati sonare. Eram sinis mansuefecisti hi. Ipsarum aures spe cotidiana sit. Tot illum aliquantulum salute da, te. Id post caste infirmos debeo sui. Qua flexu hac sum eo consumma diebus, possent igitur. Fluxum carentes.	adsurgere.AyjJAICXZ5HHr@obda.net
152904	inmortali.R47JaICxzfZhpD	Daniel Smith	Habet solae velit explorandi tenuissimas meas animus. Ac tu tuorum. Fac moles a eum velle, piam corpora teque ac. Spe potuere ago illic sim se me.	longum.74PJaf5tMCz6p@dormiessolae.net
152905	vis.cnJ70c5T6fMM7V	Michael Davis	Id melius. Sapientiorem qui ait die vis cito. Abs corruptible scire lugens deliciae facit conscius. Factos me variando promisisti digna. Seu tria abyssos qui.	bene.cGppyCithc66p@homopetimus.org
152906	moveri.0r1jY5Ishf6M7v	Natalie Moore	Debeo pax intraverunt quiescente a excusationis spe ubi. Campos condit subrepsit violis. Factum exteriora possim oblivionem parit liber eloquio teneri, id. Cogitatione nam male sine, vocantur ne. Abs sonum. Eosdem seu das ad, illic se veris, obsecro. Eis dubitant. Vix ei cui eum toleret probet dulcis gaudentes. Hic ut teque loquens aer humilem, tria nolle.	supra.yjD70ICThfhMJ@amemme.com
152907	nesciat.71dP05itziZz7u	Charlotte Jackson	Sim fuit placuit vae, facio remotiora o de. Dare varia laudatio caveam cepit ne facies. Ex suspirent invectarum iucunditas et ducere viae vi.	o.R1UjbIFxm56mj@verbohuc.org
152908	o.IVDJ0fctz5MZjv	Charlotte Anderson	Surgam aer o bono, es eum curo. Dum se re. Respice ardentius his nomino videns coapta penetro solis. Superindui. Cogo parum auram potuero parva caro magni consortium. Mediator inhaereri. Eam in repercussus sunt, ut relinquunt. Fui priusquam te hae venio re sive. Das praeciderim ait ingenti agerem.	verba.FD1pb55tMFHM7@saluteunico.com
152909	dicis.o6drA5ITHI6m7V	Joshua Martinez	Sicuti resistis corporis fraternus copiosae num vi longe retenta. E euge toto. Leges sit. Vanus nota vix. Tuetur perfusus tum certe praesentes, te sentiens ubi. Discendi rei res contemnit, fortius.	huius.wZVrBFiTHfHh7@laborrei.org
152910	quandam.JkuPaFCShfmm7u	Mason Martinez	Magni ac esset parit, praecidere. Nolit ab tot aditum traicit nolo ore se. A fraternae variis cessas quare eius. Voluptate vi liber his.	ne.r9UjY5c8Z56MJ@gravehomo.org
152911	congesta.tl17AFF86cMmPU	Mason Harris	Requiem consulentibus adest fallere alii. Huiuscemodi tua dico adiungit eis generatimque. Lege. Erat an graventur. Retinuit proprios moveat aut dona. Quaeque. Fine at doleam sanare, mentiri oraturis religione leges sonorum.	modis.t91705CXZ566r@carosubdita.org
152912	deus.bcU7YI5SMFzZ71	Andrew Taylor	Fac donum alieno. Latinae doleam quibusdam alienorum vi manducandi mel. Congruentem violari montium coniugio iesus. Sinus te sentio delicta tutor expetuntur secreto reperiret, colligimur. Cui. Eam et cor.	religione.05VR0f5S6F6mr@meloscarne.net
152913	somnis.7SvjAc5S6ChMru	Isabella Davis	Et redire. Gero voce responderunt delectarentur sequi mirantur pretium. Grex fias. Tale approbat modis.	aufer.78v705iX65h6J@osduabus.com
152914	domino.3Tvrb5i865h6r1	Emily Martinez	Addiderunt tot ad.	o.9tdR0if8H5HZr@forasore.com
152915	casu.vEUjYi5shIZMpd	Sofia Anderson	Conscribebat sed unus se ob nec metuebam contrahit et.	inmensa.1oUpYI5thi6mR@amarenthos.org
152916	non.9q170IC86ChZj1	Daniel Garcia	Soni varias intellegentis alienam erro differens. Ne deo. Amaris ea. Ad. Nam tu.	e.KeUrbcF8H56mr@cotidiefornax.org
152917	erit.neuRaIcX6imZPv	Sophia Taylor	Misericordias des videbat e oris medicamenta si inlecebras diem.	ad.4o1PAc5Xmf6HP@utnota.net
152918	solis.xNUR0558mcmHjv	Anthony Robinson	Lux caecus amo debeo a cedunt, multos, a. Es possim approbavi id. Lascivos mirari mole experiamur, tale cinerem. Ait tu subditus tua, medicina, peccatis flatus praesidens lacrimas. Modis. Dicant proximi nam viae quicquam aditum ut, eius.	o.T417YCfxMFmMr@multisego.com
152919	videat.YN1r0cfx65HmpU	William Martinez	Nec os exitum da in retranseo dum. Die volebant factis non ipse credimus absorpta unde una. Varia nec sonet a discernere. Mors sub vel.	aliquando.B21r0F5tMFM6j@eout.com
152920	ab.MJzjAiFsHCm6rV	James Smith	Aliter modi contexo videtur magnam actionibus cotidianas.	pulsant.Z7hjbCFtmCZm7@amantvanias.net
152921	sopitur.9U6J05FShIM6Pu	Emily Wilson	Modi proruunt doces eis languor interiore, deciperentur. Inpiis supervacuanea valeret da diu edunt clauditur, memores. Mortem me praeciperet ipsum sola ne.	inter.9Vmp05ixZf66J@accendede.com
152922	a.5V6p0FcSHImhpV	Alexander Johnson	Adest sit fui. Imago decus diversitate respondeat deum nec. Quis erit ei vana, viae proceditur at sonet quare. Id id referrem da liberalibus petitur. Ipsa molem nam sed.	pulsant.51ZPY5cTM5M6R@sinudurum.net
152923	fuimus.jZhPbi5sZIzH7d	Emma Williams	Eo sic verax male conspirantes peccator. Amem aliquod pax. Caveam hos.	reccido.7Zh70F5XZcmm7@meaos.org
152924	removeri.uLh7y5FxHCZZPD	Natalie Davis	Placeam ob carthaginem ex, istarum, diei conatur. Sinus teneant eum. Languores e meos bona dum lata os ego. Humana exteriora ac est fraternus adprobandi hanc eunt. Loca sui manet genus me meo, sectatur. Intonas bibo colores huc vi secundum digni, interiore. Se oneri sonus semper. Primatum efficeret o tuis. Flumina voluptas sat ab dominum mundum ruminando eo vos.	molle.1kzpb558ZIhZr@illosubi.com
152925	ait.q96RA55Sm5hZjd	Addison White	Loquens ullo tu mirum eis quanti quanta. Vanae adducor. Tamen lascivos iugo passim praestabis amat. Ne pugno surdis sit. Exitum sinus conperero magnificet hi, edendi vae vi ridentem. Reminisci fulget tum perdite, genere vel mortem. Transibo sum distorta in da potuit. Rerum dolorem ac. Alia cura dormienti ob in malitia mei perturbatione.	opertis.o967YCf8zfmmp@hipraebeo.net
152926	fit.l8ZPyf58h56zJ1	Sophia Thompson	Divitiae arbitratus fac accidit tu. Vi nimii mali contristentur, lata texisti. Meam. De tecum cum memento ideo, mei amet. Boni agnoscere cognosceremus nam hae haustum pax sanari.	tam.K8z7ycFXm5Mzp@huicquarum.net
152927	o.RW6RYI586CMzj1	Andrew Jones	Generibus coruscasti detestetur. Mortuis sub displicens deteriore, die recipit venio. Placentes sive certissimum amaris distorta intra nemo. Certa en edacitas at dicit, tuum, peccavit desiderium quaeram. Aer adhuc de ut, concessisti.	retenta.PWhJ0c5x656MJ@sciunthaec.net
152928	sono.mb67aiFxMFMz7u	William Davis	Sibimet reperiret. Amet des en e evidentius muscas quiescente. Debeo id deinde sibi oculos modi tu videant. Araneae comitatum colunt viva temperata cur ponamus meum, anima. Ego vis at est an. Hae post his das. Soli tangunt da his aliquantum capior absurdissimum.	sparsa.mBHjaf5Tz56h7@serviamvitae.org
152929	inruentes.2b6jaIfTZfMmJU	Liam Martinez	Divellit. Vivente vult imnagines meis, has tu magnus. Principes privatam cantu. Sacrilega iucunditas laudatur stilo via vix. Praeteritorum nascendo dixi canora necesse. Abs non cibo fudi reconcilearet requirunt interrogavi cognitus se. Temporis cotidianam colores vulnera intravi eo. Tot res eum illo manifestetur beatos fulgeat ille tu.	inde.NAM7BC5sZIZmp@aurasiam.net
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 152929, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1642, true);


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
-- Name: posts_author_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_author_idx ON public.posts USING btree (author);


--
-- Name: posts_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_forum_idx ON public.posts USING btree (forum);


--
-- Name: posts_id_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_id_thread_idx ON public.posts USING btree (id, thread);


--
-- Name: posts_parent_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_parent_idx ON public.posts USING btree (parent);


--
-- Name: posts_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_thread_idx ON public.posts USING btree (thread);


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
-- Name: votes_thread_user_nickname_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX votes_thread_user_nickname_idx ON public.votes USING btree (thread, user_nickname);


--
-- Name: forum_posts_increment; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER forum_posts_increment AFTER INSERT ON public.posts FOR EACH ROW EXECUTE PROCEDURE public.update_count_posts();


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

