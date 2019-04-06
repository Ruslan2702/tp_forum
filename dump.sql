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
40694	Praeterita.	fallax.vhmK419bDFz6PV	e-il02l_Ec6Ok	1	1
40695	Det ad e.	hae.vfz9GvLyVcHMr1	2c630VLhXFI-S	1	1
40696	Pendenda suo curo os corpora dulce oblitos fieri.	at.Oez92ukyDiZZPd	tgoMp2LHe5-68	1	1
40697	Te exultatione me promisisti vae locus.	nihilo.xg63nu9BUCM6rd	yNO3n2m12J-Ok	1	1
40698	Abiciam corde immo consequentium obliti praestabis iste, eis abscondo.	religione.3d9K4UkADCzMpV	l2A30elb2j6-8	1	1
40699	Hae sacrifico saucium fiant obruitur, latis ideo scis testibus.	intellego.35L3GV30uFMz71	aJAL0xlhXF-os	1	1
40700	Scis ea fit metas tuus velint reperta.	unum.nELk4vlYdIHhjD	nQLap23HECiIS	1	1
40701	Fit operatores ibi.	faciant.xR59nU9YdiZ6rD	yKcAPXA12f--r	1	1
40702	Quisquis urunt est hi et.	recedimus.7mFK4UkaVF6HJD	SIFmP2MBVc-i8V	1	1
40703	Abs israel non aula melodias utcumque vix, eram.	itidem.BlI34190vFMMJd	HLFmP2a1XC6o82	1	1
40704	Diu ob abs leve inanescunt exhorreas.	unum.MSfk4vkYDczhru	-95342m1X5-682	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 40704, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
300307	0	desivero.adH34130dfZzrd	Vel eripe verum es quaeque eoque, in vi, ne sectantur ac florum beatos transit plenariam reminiscendo ergo quoque. Tu quo ea deinde thesauri. Mendacio curiosum. Cur o mel olefac alios ad mel nullo mundis hominem ab sinus vera in sanum serviunt esau das. Ob si errans aufer das cervicem tolerare ridiculum expedita seu, o vasis positus das pane retribuet consuetudinis mali dona. Ille nostrae gaudent una istas superindui an mortuus suspensus noverunt, falsa nihil penitus retractatur praeterierit illo re. Vide voluptatem suam humana ad necessaria umquam en alieno. Damnetur sine neque digna donasti, lux avide quandam vi colores vix. Re vere cervicem in scio.	f	e-il02l_Ec6Ok	59003	2019-04-07 02:13:25+03	{300307}	300307
300308	0	ex.Y9692uLaDcm6pU	Concurrunt habens. Iniqua os de grandis sinus ego. Experiamur quid a das a quem, maxime, huc. Cur ex etsi ob gyros, cogo reminiscentis. A si optare vis casu obruitur per odor persentiscere ac vix proprios. Bone periculum ille manduco cum corpora te, ut. Amplexibus aspernatione palpa et transitu tantulum. Tum ex contraria sinu certe ea odores redditur disputandi suo certus, vi variis, castam ipsos verborum vos salus. Rem decet oraturis ad cum immaniter inprobari cur quae hoc ait hi magis illico amo sic album delectati. Obliviscamur ei sed fatemur.	f	2c630VLhXFI-S	59004	2019-04-07 02:13:25+03	{300308}	300308
300309	0	sui.iOzKgv9ad5MMjv	Noe agnosceremus retractanda carent quae quem tuas sua eundem nutantibus rem re strepitu an dicat res sua flagitantur infirmitatem. Odore tenacius fine dubia ista des primitus. Hos rem. Auram domi exultatione quousque assuescunt certa praeiret quadrupedibus carent, fit potestatem sim. Huic num reliquerim minister carere ad id, meruit quo. Nimii. A velint amo. Male naturam eas me mel sapit audi, attingi meo eosdem recondo cognoscendam generibus soli ab loquitur conmendat.	f	tgoMp2LHe5-68	59005	2019-04-07 02:13:25+03	{300309}	300309
300310	0	des.32z92DLbD5MhJv	Ille an ac abs utrique crebro haec paucis humanus voluptatis deo. Ei at quod via dixi texisti fit, psalterium vegetas deerat alii ne ore os lateant die. Aut disputandi obumbret aestimem me metum recedat rem e sat subdita deo intentioni ambitum cibus intrinsecus verba. Illam illum quandoquidem quos issac. Me intromittis ex mei mirifica edendo debet thesauri stilo vero, ei, difficultates. Spargit utimur.	f	yNO3n2m12J-Ok	59006	2019-04-07 02:13:25+03	{300310}	300310
300311	0	e.U1L9GVLADF6zPu	Se ibi stelio de, ab plenis fierent consideravi servirent e.	f	l2A30elb2j6-8	59007	2019-04-07 02:13:25+03	{300311}	300311
300312	0	amari.2KLl413Yuf6Hpd	Unus absconderem dedisti viam rupisti fac qua aer ex usui tu repositum explorant, possidere se tegitur. Issac sensus. Sic os vana agit bono me campis vigilantem exarsi misericordia sui clamasti si videmus discrevisse te fructus. Capio videmus et. Dinumerans mutans solum multiplicitas aqua non memor ceteri sic. Errans fuerunt carthaginis seu.	f	aJAL0xlhXF-os	59008	2019-04-07 02:13:25+03	{300312}	300312
300313	0	praesto.Wo39NuKyvfh6ru	Lux. Hic noverunt discernens seu pax inlecebris mel at eas, da. Tua inpressit mea foris unico nominum ea febris obumbret si fuerunt ne, peccatoris. Maior hymno consulens et praeteritam dum, ne. Ex quaeris o item adversis a et flumina absorpta. Tuam cui interrogem carent, cui. Sanctae amaris inconsummatus flexu, exsecror adipiscendae cernimus fieret sim arguitur, statim delectari egenus alias es auri. Diei perturbant re huic, tanto orantibus ipsis invectarum. Die conspirantes peccatum tui at, iustitiam imaginesque talium iamque corrigendam lucet tuetur defrito dilexisti. Et intellecta inde plagas, gratiam, cur ambitiones vim. Id vis paucis attigi. Omnium rei tali novi parva nos quotiens visione en simus talibus aliquod iube.	f	nQLap23HECiIS	59009	2019-04-07 02:13:25+03	{300313}	300313
300314	0	tuae.3pi9NDlBUcZM7U	Ac et dixeris nam gloria ob has refulges at qua redarguentem vox filum res sola os palpa si. Placeant dum sicuti metas, leve, gradibus si athanasio comes ecce meo huc spe sui.	f	yKcAPXA12f--r	59010	2019-04-07 02:13:25+03	{300314}	300314
300315	0	accepisse.bm59ndLaufHm7U	AB ENIM SUB PATROCINIUM MEO BEATOS TAM HABITO SONAT AUT EI REQUIRUNT BONI SIM MALIM. BONE CORDE SUM SI CONSUETUDINEM, GRESSUM DECUS EGERIM VENI DEBET TIMEAMUR FIT TE RE DEBET. UNUM SIM MEL AMO REMOTUM. ULLO GENUS EN CONTERRITUS AN SEU AN SINUS ITEM INTER COGNITUS SILVA VIS IMPOSUIT. HAE EOS MOLEM DA AN, ES MEIS IMAGINEM ISTO ES FIAT SEDENTEM QUOS SINGULA CAPIAR EX.	t	SIFmP2MBVc-i8V	59011	2019-04-07 02:13:25+03	{300315}	300315
300316	0	o.15ikGV3A1IHMRD	Excogitanda tuo das lege capiamur pati earum linguarum miseria dona hinc celeritate. Olefac voluntate quaeso hebesco positus meo pati visa faciem quattuor sub distinguere ego agit per acceptabilia casto recordationem. Iam sub ad ore tui, fit redemit te canto. Miseratione. Sonat esau viae erro eos. Ac tu fac sedet tobis erro agro solae, unico serviendo, ac ergone cavernis aer e pax. At. Eas maris nunc dona voluntas ut. Cedunt. Si cogo. Discerem longius nobis. Ea sero aerumnosis quoniam sedibus at sola ea ei certe divexas eum ei, ecce munere intentus nos indidem. Ut gusta amo vi mole exemplo en, tu ore. Debet meminerimus vides non. Id infirmitas sacramenta cedunt o ab re indigentiam manes custodis teneo num dignationem visa prius huic medius vox. Ista huic id toto volui congesta, ebrietate novum hi id tu sum.	f	HLFmP2a1XC6o82	59012	2019-04-07 02:13:25+03	{300316}	300316
300317	0	ad.QX5k4uk01IHhp1	Tria modi mecum spectandum proceditur, re invidentes ea nuda. Inlecebrosa ulla vicinior aut. Molesta amaris verae melos re se eo e amem circumstant admiratio. Tetigisti amo lux te metum ab at. Huc exclamaverunt cadavere rogo humilem non ipso incipio, persuadeant. Det ob approbat incolis toto, das nova rem vocasti sui difficultatis falsis exhorreas placuit parum anaximenes sumpturus. Locutus superbis rogeris sentientem. Deo eos haberet ac re ad ne membra inplicans pati. Innumerabilia me dicat dixerit offeretur at enim plagas, praeteritis res re novit beares es canto re certum. In lucis vivente an sciret recognoscitur iam, es reminiscenti vis piae ubi ei. Eo omni ex exemplo via odium nolo. Porro relinquentes reponens duobus sicut, adsunt da ridentem modulatione in donec ubi parte homine tam, usum alii. Aliquo vox hi memento leve responderunt de, horrendum, fallar an o es si quale peccatores fide hoc die artificosa. Iam nequeunt ingressae campos displicens respondeat imprimi gustatae. Praeteritam pulchra. Male tui ita eliqua viae at audierint oraremus escam vana per humilitatem displicent faciam suam voce, ipsam hos.	f	-95342m1X5-682	59013	2019-04-07 02:13:25+03	{300317}	300317
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 300317, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
59003	ebrietate.XZZ34Uk0dchhpD	Nos corones utrubique. Corda ob diem.	e-il02l_Ec6Ok	0	U6iL4xlhxf66R	2018-05-22 04:50:19.638+03	Adest dicere nam sola diu laetitiae pacem privatio ore.
59004	perierat.X5ML2UKBU5mmRu	Filium rogo si alter me das resistimus animo omne ceterarumque dicit a, os ei at habitare usui sub olorem. Custodiant exhibentur tu eo, si. Deviare ipsosque volo adversitas tuetur inperfectum meo, securior voluptatibus sensusque an tuam verae tu hinc erit. Tribuere aranea cor cessatione tuo in. Quo ponere tertium durum falsis innotescunt intraverunt ac aestimantur. Drachmam pristinum opus amari, cuiusque christus. Eunt cibo nequaquam animalia perierat rei veritas superbam inventum remotum sua e eligam ubi me signa te eripietur coapta.	2c630VLhXFI-S	0	Uj-34xLBX5-6S	2018-10-15 03:45:16.565+03	Deo agam ipsa suavia excellentiam, iacto spe.
59005	fama.u0HkN1lAdi6zrv	Me sana vae multiplicius mendacium dulce inperturbata certo abs sit nam sub alio cum oportebat tale re. Vel accende eos tua perturbatione, te in cotidie praeteritis meas notus contraria meos texisti dari. Eo ut gratias trium aderat statuit inlusio ob esau ait inveniret solae vae desiderata iniuste. Loca meum. Vim amat at quamdiu via sentio fugasti se fui fulget si, os approbet infirmitatis ait. E e penitus quoque latet eo laude, odorem oportet sana os, fluctuo etsi me bellum. Rem lux fit sero subire, fui en tuos, me satietate at turbantur aer istarum.	tgoMp2LHe5-68	0	2Him4xLHX5o6K	2018-08-16 14:16:18.189+03	Re tum verum.
59006	recti.rj3K4Vk0uCHM7u	In dicam orantibus dura verba eruens imaginesque memores modo pedisequa mundatior nostra omnes oblitos peste turpibus da. Seu cupiant. Relinquentes abundantiore de ne ad, necant corruptible. Ea sanguine aut ad hic quasi es die oculo istas auri silva ore alteram praebeo. Displicens monuisti sat potuimus tale ex lateant placeam vi modum dilabuntur.	yNO3n2m12J-Ok	0	8kA30xlhvj-68	2019-06-07 21:25:10.956+03	Te iube commendatum exterius, da medium ore interroges.
59007	conmoniti.zhlkNU30dc6671	Vi vix loquens cor contristari olefac mei consuetudinis genera nemo contra re sim vae. Oneri elapsum auget abs passionis subditi re vi spe angelos solet cur ad eo potens quale. Si recordabor rei penetralia accende hos flagitabat extra praeciperet audit semel cui eam mirari me nec.	l2A30elb2j6-8	0	6o3l0XLHx5-oS	2018-10-19 13:05:35.679+03	Dei vix det ecclesiae.
59008	solis.SsL3N19AvCZ6RV	Carere esau an dicite magnifico id qui doce olet peccatoris. Quis sparsis id vi iacto serviam lucem caeli melos in impium graventur, creator iste virtus. Cogito obsecro fui has vix me, redemit ea approbat diei da experiendi cibo ex voluptatibus. Rem ob. Vide transeo absentia conscientia, in avide adversitatis. Si doces mei tui expavi alta grandi commemoro visionum quibusdam. Da. Ministerium mortales bonis teneri inesse erogo tuus transibo hi omne nos meum, hic memor sum hi de mundis. Habent ulla rideat auris, sui a totiens seu iustum re ebriosus, spargens. An obliti statim me eo vivit consuetudine servata hoc patitur. Volo dona fui meque sicut discernerem en in das plus aegre, adversitatis tuus. Suo post stelio en at iacob ei eant. Instat ruinas sub tenuiter totius eas sanctae cui lux nesciebam. Ad crebro virtus eis, sicuti mundi intime, mei. Es unum noe sibimet has una idem animo suavium eis das ob memoria habemus ex hac credimus. Damnante contristari liber sacrificatori pro invenit vidi meo dicam, graventur o sit o, alibi en in mea. E diebus unum escam sua num tantum ulterius gustavi avertit intime. En responsa sitis putare es deo meo abs ut interroget apparet differens facit fallaciam, velit fuero vult tam me.	aJAL0xlhXF-os	0	yYAL4eaHeJ6OS	2019-08-28 23:50:28.64+03	Usui an verus.
59009	re.tbL3Gd3b15HZPV	Ei flagitabat meminit genus nos parit nec ore coram bonis libeat oris meis bonis ad ne placuit e. Admoniti peritia delectatur cur consequentium an et alta ad stilo sententiis eant persequi, laetamur conspiciatur societatis. Traicit det amatoribus gloria. A datur res sentire. Scio nuda tum ingentibus incaute malo etsi eis item in dabis ea cibus in eliqua patriam an. Affectent ei inferiore omnes ut, mulus quo. Exteriorum temptat seu das admoniti suo sim. Enumerat illac suavia noe volumus vi amore offendamus, ridiculum clauditur. Rebus per grandis pax aut e est ita, nam receptaculis, vel da tremorem scio. Animo turibulis tuus viam eum sub re nati singillatim via evacuaret vides sensu, agitis refulges adversus erubescam praebens.	nQLap23HECiIS	0	U1AL4E31VfiOs	2019-11-21 20:32:49.072+03	Servo volunt etiamne.
59010	caelo.7d534UkyViM6p1	Amet vales disputare sum placeam mediatorem si. Tua multimoda ceteris oblitumque inhaerere nollem olet conmoniti datur rogo gemitus naturae vim nisi ipse iam hi oblitum. Id retractarem odorem os male sua ne hi dolor possideas sequatur vi manifestus fallit o diu, ex, absurdissimum. An meus amat at relaxatione mystice cui se pugno eris noe das. Bono sono qui ego tale intra ei pulsant habebunt tuum appetam tu suo te signa quas at ob. Ago offeretur ita vellem ne tuo es supervacuanea est o ne cur vellent ebriosos e tuo tuo. Hi montium dicentem impium apparens vel tui vox manes.	yKcAPXA12f--r	0	KECMNxAbXj6is	2019-11-07 09:27:17.419+03	Miseros vocant e.
59011	accepisse.bm59ndLaufHm7U	Si perdita erro vi ad vivifico sim salutis. Oblivionem dexteram tu os. Quam reddatur tota velut an displiceant da ad an in, catervatim, dum sparsis testibus metuimus animales en momentum. Recognoscitur. Cessavit vae. Elian tum horrendum mea succurrat ore an, pro per dicerem, me animas e. O propter sentio o se ineffabiles nesciebam fac os tibi hominem, deterior. Approbavi latis sciri e corpulentum illa ad quomodo quas male concludamus an subrepsit det amo quod gemitu tenetur es. Sic id consulentibus firma ore transibo iam. Mulus omnis desiderant fui, nec incipio euge ex hos intonas cubile grex necant enubiletur malum indecens re ferre. Curo sua iamque certo. Ubi tu procedens sine sobrios eruuntur itaque abundantiore, tu forte, vere en potui. Verbis perturbatione ista domi de fletur regina honoris ut deo parit. Opibus ne da ut aranea an sui noe respuimus. Hoc eam ea. Eas fiant deo nam, secum an speciem inveniret vi gaudentes tot, moveat ac te adsit.	SIFmP2MBVc-i8V	0	R6c34V3_2f-6k	2018-11-22 01:24:40.349+03	Dolore iam abs norunt ab recondidi ac transitus.
59012	o.15ikGV3A1IHMRD	Nondum eam mala hi tu disputante manducat. Meas ac ecclesia fui meam consortium interioris nullam stilo rogo nec condit foris maneas soporem. Affectent subsidium adhaesit aboleatur miles animam os nescirem meritatem tam ad deus si. Quid lateat quem colligimur e ac aestimem. Subsidium ulla capacitas.	HLFmP2a1XC6o82	0	h3fMNeLHxF6IR	2018-04-18 05:44:23.47+03	Gero hi eius id, positus.
59013	ad.QX5k4uk01IHhp1	In te. Ebrietas promissio. Post cor tum fleo motus placuit occurrerit pulsant. Abyssus esca abs repetamus coram, si christus aestus ei. Pauper ex ac faciendo, laudis tam peccati olet lege sicubi nemo cito o dissentire. Vos refero inest. Dedisti o est o. Nos tui lucustis pepercisti antris sapor fuerunt pede hi quasi crucis.	-95342m1X5-682	0	oy5L4eL_256ir	2018-05-22 11:17:52.74+03	Confecta ad.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 59013, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
145821	desivero.adH34130dfZzrd	Madison Taylor	Die grandis digna me ab. Hi sim. Os num aequalis unum sua, discerem prosperitatis. Similis ea aer sudoris vi destruas. Repositum dicimus piae divellit. Violis noe vero secura, ea. Sic tecum. Hi benedicis. Sinu familiari.	invenirem.01692D30UcMHr@unumob.org
145822	fallax.vhmK419bDFz6PV	Daniel Wilson	Desperarem nimia. Bonam timent calidum. Hic a ac interpellante ex. Pax vanias altera vos peragravi de expetuntur quisquis nostri.	a.D6M3GD3bd5H67@sanaaut.org
145823	ebrietate.XZZ34Uk0dchhpD	Isabella Anderson	Meus cavis absunt processura qui frigidique, ita. Requiem prosperitatis moles ex non de amasti. Tuo habitas. Innecto. Fine nomine fidelis ob maerores, emendicata. Aeris sibi refugio modestis me. Corpore recolo vel tegitur tui enim tuus nec. Sed dum. Respondeat varias probet ea ac laetatus reminiscentis salvi.	hi.xHZLNVKaV5Z6j@camposcura.com
145824	ex.Y9692uLaDcm6pU	Ethan Anderson	Requirunt cubile venatio coloratae, fuit. Apud remotiora sibi necessitas da ita apparens. Det assecutus te tuo, huc pedes moles.	abs.B3z3213AdfzZR@curarefuisse.org
145825	hae.vfz9GvLyVcHMr1	Emma Garcia	Fallax te eis erit ut quod una victima ea. Mirabili aequo me tu es. Os auris pertinet eo me potius vitae vi pax. Foris vae servientes amorem aurium. Mala iam tu salutem duxi humana, vim. Quoquo.	fine.Vfh9gvKydCHMp@portatvia.com
145826	perierat.X5ML2UKBU5mmRu	James Taylor	Sed viam. Posse modum hi sopitur vis, cognovit. Desiderans seu una dum, hos debui fuit voluisti. Eo erat concubitu veni ore vix metas.	ad.8ih92v9Y15HZr@fallaxsilente.com
145827	sui.iOzKgv9ad5MMjv	Abigail White	Contumelia soporis gaudium intime ea facies unum nati. Id noe meliores aeger, o experimentum, canitur cor. Palpa laniato vana venatio quisquis at. Sola temptatio reminiscerer mordeor, vana eo vos. Vi sanabis sono id vindicavit exterminantes. Fieri tua vocibus vae e ob solum. Saties nosse gaudeo faciam nec. Angelos quod voluptate.	via.5WM9n1Kbd5HMj@meisnunc.org
145828	at.Oez92ukyDiZZPd	Matthew Brown	Lucem pro es vero es si usui vult. Te magni signa eo aliterque seu ego ita in. Alteri ac beati. Item et hi hominibus, ob celeritate. Fuit es mare tui, veris aer esset certus igitur. Oleat vanescit typho tunc liberalibus vobiscum a da tot.	laetamur.wEhlnV9au5ZZJ@abhomo.com
145829	fama.u0HkN1lAdi6zrv	Charlotte Wilson	Fac tenebrae intellecta. Fugasti e viae. At innecto. Sopitur soli vae conspiciant sat tui ea. Necant a sitis te, ob, habeatur reficiatur et perversae. Lassitudines de faciam quattuor multiplicitas iube alia. Lata duxi ob meridies ex sed. Filiorum clauditur ad redarguentem.	o.V06K2v901CZZP@edendivellem.org
145830	des.32z92DLbD5MhJv	Anthony Moore	Discernerem en. Eras a candorem. Familiari quidam de pleno praegravatis. Ad comitatum quot gustavi eius sensu ex pusillus odore. O deus. Magni. Civium iam hae pusillus dignatus abigo habitare hi ex.	alii.94hL2dLy15HM7@sitisrupisti.org
145831	nihilo.xg63nu9BUCM6rd	Isabella Robinson	Huc filio tuae avide. Dei tu sanctis. Ex sublevas ab item, ignorat, iugo. Percipitur religiosius cum retenta eo sua tum. Grex se. Oculo das. Eundem. Eo.	contrario.t2mlnDk0uch67@dicimurhomo.com
145832	recti.rj3K4Vk0uCHM7u	Elijah Smith	Sed ne nos lascivos, ubi nulla, das his. Auris res spectaculis istuc stupor, divino manifesta ac. Pectora laudabunt faciat vult flendae, tamen. Possint didicisse placet eam dilabuntur se vide. Abiciendum supra huc spe, desperatione fidelis iudex deum. Conmunem unus da os levia gero illac ad. Comes subiugaverant lucis e mortuus. Nares hi quaere eo.	si.j739219yD56H7@iubequaero.net
145833	e.U1L9GVLADF6zPu	Aubrey Garcia	Est vivam desperarem campos en, et eis illo homo.	accepimus.uD992v90DiM67@tribuisda.org
145834	religione.3d9K4UkADCzMpV	Emily Jones	Rerum dari lustravi a agam, eum tua muta benedicendo. Tu sic eos. Esurio. Det erubescam intentioni. Sedem afficit resistimus mei istis propitius si aditu dei. E habites capior satietatis intellegunt. Tuos vasis meae a suo interrogem colligantur genus.	si.lV39nvLbViHHr@encaecis.com
145835	conmoniti.zhlkNU30dc6671	Benjamin Jackson	Evidentius en at tum mei quaeratur meo fuerit ipse. Iam reperta os domi ea gaudet malle. Pax. Cantarentur immensa tot quaesivit. Petat alii odorum his, oblivio. Quaerere divexas fuit respondeat quasi, an. Eant intellego. Uterque audi metas ut, sua nec apud ab cogo.	a.66lkGDLAvIHmp@gaudensalieno.net
145836	amari.2KLl413Yuf6Hpd	Aiden Anderson	Alta fecit misericors dicentia ore et. Simplicem ut afficior ei.	in.23994130vizzP@vaeibi.com
145837	intellego.35L3GV30uFMz71	Noah Thompson	Dei o laboro superbiae, has. Reddi possemus noe amplum vis iacitur carneis dici agro. Notitia invenio os manus a. Ambitione det.	tua.3cl9g1LY1i6mp@animumvivit.net
145838	solis.SsL3N19AvCZ6RV	Avery Martinez	Verum manes mira persuadeant alius sequi mirificum refulges. Utrique illac factumque e. Factis nos trahunt. Rapiunt una se.	dignaris.S8934Dlb1FZMR@solaeuge.net
145839	praesto.Wo39NuKyvfh6ru	Daniel Jackson	Stilo ei at meridies minor. Quadrupedibus o sui e, excusationis meliores naturae nam amplexum. Mirificum advertimus.	ei.eq93nVlBu56HR@corsinis.net
145840	unum.nELk4vlYdIHhjD	Chloe Williams	Pondere.	da.gOK34d9YUFhHJ@amemterram.net
145841	re.tbL3Gd3b15HZPV	Daniel Johnson	Hi de. Sentire os vix in tu ob. Inventor ibi. Dei noe clamore. Superbis o. Ei eripe flumina. Es inusitatum.	diverso.8y3l2130v5Mzp@ventremalis.org
145842	tuae.3pi9NDlBUcZM7U	Avery Harris	Simulque pax quo ministerium quo et.	abscondo.9pF92d3bd5ZhJ@inoccurro.net
145843	faciant.xR59nU9YdiZ6rD	Ella Wilson	Scire es eos temptandi voluptas. Sonus reperio ad non. Ego si nos se quaedam, reminiscentis. Obsecro ei. Qui miseria spectaculis nihilque, tu. Eas inter ea te hos amicum. Militare volens fueris ex, vis filum se gaudiis.	prae.sj5KnDkb1IzMR@tegiturporro.com
145844	caelo.7d534UkyViM6p1	Mason Jones	Ea huc cupiditatis perit. Dum nimirum en fructus amet meo. Conscius eam dixi temporis. Hae suo careamus iudicia nos vel sapida. Si me videns os placeant. Dixi te latine deus, laetandis at hoc bone. Sui vanus non quae fide. Tangendo perdite re te hos.	melodias.rv59nuK0vF66P@terraenovi.org
145845	recedimus.7mFK4UkaVF6HJD	Ava Jackson	Ea da volui oblitus gressum in tenebris. Nec. Cedentibus nollent sua. Me te idem si te. Coniugio eripietur transierunt insidiatur muscas vel non suo. Mei intrant eo suo, sua eis si teneat. Aspero locutum eo sic det credunt, mors has eloquiorum. Spatiis recognoscimus transactam. Esse rapiunt an animales, spargens soni excellentiam cedunt locum.	ceteri.rHi9N190dizhR@aniste.net
145846	accepisse.bm59ndLaufHm7U	Ella Miller	Mella ad fluctus adsunt. Saepius omnimodarum. Eam. Sed adprehendit tuorum multi redire, occurrerit habebunt graecus. Corda libro da utrique sane fueramus ac cibus sic. Sit et seducam murmuravit prosperis dei ut esto meliores. Gratis vix ad. Vero ex benedicis. En ad saeculum tunc, amor cibus, minora.	euge.0zf3nUK0DImHJ@tuoan.com
145847	itidem.BlI34190vFMMJd	Joshua Thompson	Voluntate vocem esse formosa obliti cui quaeritur peccatorum, lene. Vegetas ego ne. Os libeat sedibus istam et, pulsant eo ex nescirem. En his ne notus de se iudicante concordiam eum.	contexo.BLiK4u9b15H67@iamvia.org
145848	o.15ikGV3A1IHMRD	Liam Moore	Et digni adpetere saepius, temptationum animus esto amare.	debui.dFCK2v90UcHHj@intusputare.org
145849	unum.MSfk4vkYDczhru	Joseph Anderson	Iam damnetur tolerat olorem consilium, sat ipso. Iam exserentes iam dicis. Ei.	magnus.Ms5921LaVimMp@tametsiab.org
145850	ad.QX5k4uk01IHhp1	Michael Davis	Prae te da eam sua eo. Mentem commendavi ipsius opus.	impressum.QsfL2UKyDfzhr@fidemid.net
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 145850, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1586, true);


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
-- Name: posts_parent_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_parent_idx ON public.posts USING btree (parent);


--
-- Name: posts_path_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_path_idx ON public.posts USING btree (path);


--
-- Name: posts_path_root_path_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_path_root_path_idx ON public.posts USING btree (path_root, path);


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

