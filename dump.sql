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
-- Name: update_posts_count(); Type: FUNCTION; Schema: public; Owner: ruslan_shahaev
--

CREATE FUNCTION public.update_posts_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE forums
SET posts = posts + 1
WHERE slug = NEW.forum;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_posts_count() OWNER TO ruslan_shahaev;

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
46722	Da sonum redire gaudeant nescit voce sub.	vi.Ryjtow0YZchzJU	8BkUZG_hIFOOs	1	1
46723	E vim.	vides.MJV8OE0aMiHzJ1	ORvuGZB_ic6-S	1	1
46724	Tradidisti aquae deceptum.	alteram.aMvxQwB06ChhpU	H6X9QTBB6F6oS	1	1
46725	Una evelles re tria.	e.OFvsqoaB65ZZ7U	g5EwQgB_IFo6K	1	1
46726	Gradibus ac suaveolentiam certa habitas tu.	tuos.ioutwwYB6CZzPd	czeugt_1O5IiR	1	1
46727	Oculorum es solem qui estis, ipsaque repente.	fleo.04DTqWa06cMzrU	1NxUGGhH6jO6r	1	1
46728	Sub ad ab laqueis boni medium et haec, eum.	o.Ev68wqBAH5ZzP1	QXI9ggHH6J-Os	1	1
46729	Fuerunt.	volui.i3M8WOAbmfmmrD	ClIUzgB1iC-6S	1	1
46730	Augendo soni domino transfigurans.	fidei.5T6xoeAYmcZ6jV	5W-9QG_Boc6O8v	1	1
46731	Lucustis intentioni ac sum vi ullis.	latina.60HtQqbazizZ7d	61OutGh_IJ6Ok2	1	1
46732	Alta capiamur mei hominum meque ab inpressa alis ei.	e.44MtwqYymIZmPd	4N-uTt1bIJII8E	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 46732, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
378640	0	eos.eOP8oEYyHchZ71	Ambitum mulier credimus da meo. Difficultatis vox sacrificatori. Illo. Ea des de quasi iustitiae enervandam illic amarus tua eos multi dura desideravit, pro isto discernerem ita. Ne nova se vide, ob. Se sonum salutis amaremus. Salutem divexas depereunt sana hi, es vita, suo alas. Asperum adpellata cogit iniqua lata pulchra vis hae sat ob munera. Multique frigidique ibi creatorem auri. Exterioris numerans te lux unico id ipsae mediatorem secura difficultatis ad transitus intonas gero. Eo factus en an stat potes audiuntur qua hi extraneus diu manus doces cordis experientia me illi sedem te. Ob moderatum eam e obruitur nescio putant.	f	8BkUZG_hIFOOs	67880	2019-04-07 14:51:01.669725+03	{378640}	378640
378642	0	a.N2PtQW006cM6RD	Supra nec tuae ac ut sic conduntur quid absorbuit cessare ea aliquantum ipsis quae locus sed. Colores ac voluero de eum diu dei ubique non damnetur eam videor, intervallis. Delectatur aeris. Memini amittere mei ne scierim sua propria vim officiis ad stet ante te repercussus. Vivente salute ea quantis gratia conexos ne fudi nunc iudicia en crebro noverit, vi in fraternis eis ex. An tum hi pectora fit. Mea ceteros id da ibi cui nutu inciderunt peccare velim cibus retractanda, te ea obruitur fias. Cogitare blanditur via das rem, transcendi si quadam sim ita num, occultum via me se. An ad me paratus o mala a tu an loquens amem sero. Nolo tu putant ago dicens munda memor. Inhaeseram amorem interrogem vis. Vigilantes spe ego amo vi nolit a febris duabus pax mel das plenariam ore talia clamore intellegunt recordantes iam.	f	ORvuGZB_ic6-S	67881	2019-04-07 14:51:01.688182+03	{378642}	378642
378644	0	cantantem.xM1teoyA6imhRV	Tui quae laudavit seducam, attamen ne loqueremur. Huc imprimitur istuc malus, o. Sequentes innecto ne molestum esse praetoria fidei aliter timeri ita cedunt da vos ascendam sepelivit. Faciendo recessus novi me e si lux vero spe. Iaceat de tot nova, id dare considerabo. In. Discere mulus inconsummatus es tuo videat, sim et contra commune vis circo. Da haberet quidem te det sim diu. Mea. Aut o ut vos mittere. Facio dici una mortem ingerantur illac ea da contrectavi animarum illum adamavi quam quietem ut ad.	f	H6X9QTBB6F6oS	67882	2019-04-07 14:51:01.710302+03	{378644}	378644
378646	0	o.CidTQq0aZfHZRd	Haeret flagitantur ut reminiscerer res nuntiavimus affectum a in sit quaeso, adtendi cor cogo accipiat est talia iactantia penuriam. Excusationis imaginum hominem. Deerat non aderat sedem vix ei des, illuc audierunt die quadam nos vox praeposita de ubi hi. Vix gavisum se rogantem et a mei seu victoriam alta es eruuntur. Fortius peccare ne afficior ore urunt pervenit his latine me unde. Ad. Bonos scientiae praesides voluptates, diei subtrahatur suspirat paratus erit sane vi. Videtur nisi duabus dari si. Dormienti ut siderum. Gaudii deterior hos continebat levia. Aer munda interiora leporem quem servirent e aliae se campis pondere sudoris corruptible horum moveri. Iube populi tuo haereo ita sectatores viam. Cavis hic gaudeat interrogari tali illam an dominaris gerit equus rogo plerumque resorbeor audi templi aspernatione ut. Peritia superbi fierem credita modo suo pius conpressisti multi amo a. Visione eo hi circumstant meam ne digna o totum an iam resistit hoc. Praesides amore alas venatio tantarum ioseph post seducam, volito gemitus hoc tenuiter nati an vicinior contristamur hos coniunctam. Amplius rapit. Rem cadunt vos inpiorum, intonas os plena eum.	f	g5EwQgB_IFo6K	67883	2019-04-07 14:51:01.727328+03	{378646}	378646
378648	0	diiudicas.hqusOqAAHc6HrV	Eam suspirent intellegentis ab a erogo id, in se eos interponunt. Ea iudicanti hos vel tanto ac nolentes edunt, mittere naturae cogito flatus an. Omnium perfusus viva vocatur. Ea. Ait dignitatis dari abs se certe agam deo copia diebus hi tenebris. Aspectui e vocem consideravi nolo id oculus. Nonne tuas antiqua defuissent, ore recedat. Placeam auras sectatur abyssos tuis ei salutis quiescente illuc excipiens eos cogitamus inpressit lege coruscasti ne. A id didicisse det equus posse locus ingredior deum habes similitudines corpulentum dextera ego. Paucis duxi caput cuiusque capior ulla ridiculum teneor delectationem. Amorem inconsummatus nam dura amo. Nares. Est ob portat sine et valentes eunt. Vel sint aerumnosis obsecro, oraturis curare, quaerens bonam dici cessant sub an istis inhaerere fudi. Os. Parte miser tu laudibus manu cadere nec tui cum signum o pecora. Et cibo en at en cedendo ex da eis, infirma, direxi corpus sat recondi veluti colligo da.	f	czeugt_1O5IiR	67884	2019-04-07 14:51:01.74717+03	{378648}	378648
378650	0	atque.fg1xQO0B6Chzjv	Mors alio sua reperio sunt adflatu ob omnium te idem saepius vos miser tali. De hi considero medicamenta reperta credituri vix in se si ulterius discendi erubescam ei notatum. Tui vi aut videns has porro aliud. Aquae oleum dolor verax surgam indicat scit cantu animae, lascivos, et spem illo adprobandi tale te. Pater corde o. Qui fui. Severitate quo eis est suaveolentiam petat eo eras aliae.	f	1NxUGGhH6jO6r	67885	2019-04-07 14:51:01.763526+03	{378650}	378650
378652	0	palleant.3dm8Ww0Y65MzpU	Res ne afficit. Ut te pati os hominum. Aegre da sanaturi similis.	f	QXI9ggHH6J-Os	67886	2019-04-07 14:51:01.780173+03	{378652}	378652
378654	0	a.6KH8wqbBM5Mzju	Vae aer mors metumve vivarum mel eloquio illum tua die tuae at te si. Est meis det nam innumerabilia id at, similis iam relaxatione multos ac usum ascendens hi una ob. Quid sapit rogeris ait quicquam das se notus ponderibus. Afficit audiam lux. Ita videbat vitam plus manduco creatorem agito a transcendi nos da viva minuit, meridies exitum. Suggestionum fac olent quaerebatur meus terra ago hoc se influxit malo eodem vituperari luminoso sciri meo recognoscimus via. Meruit pollutum.	f	ClIUzgB1iC-6S	67887	2019-04-07 14:51:01.801777+03	{378654}	378654
378656	0	in.2ShtWqbaMf6MRv	SUM OS INSIDIATUR MEIS MERITO NUTU EX, AD VELUTI ES ELATI PATI, SIM EN PULSATORI DES HIC NUNC. DIVEXAS DUXI OFFENDAMUS AC EGO PETIMUS EN. MISERA SURDIS. HAE MEMORIAE IUMENTI MEMINERIMUS IUSTITIAM, RE. AVES AMISSUM CAELUM CURO TUA MINUIT CUPIDITATEM DET DES EA CONMUNEM MAGIS. AB.	t	5W-9QG_Boc6O8v	67888	2019-04-07 14:51:01.815134+03	{378656}	378656
378658	0	tua.WYm8ee0AM566Jd	Velim laetusque reddatur saluti tu rationi imitanti etsi id illuc ac ad possideri praeciditur aliis. Medius pedisequa has penetralia debui moveor spernat parva toto demetimur hoc mea at o castam. Istarum succurrat capiamur ubi iugo cognoscendum de ubi credita sacerdos bonos usui gaudiis sonat intra me tuas illos seu. Si temptat ametur.	f	61OutGh_IJ6Ok2	67889	2019-04-07 14:51:01.830756+03	{378658}	378658
378660	0	muta.TjKTowaaz5mhJU	Potius aut deo dormientis nati. Bestiae sensum eam rei confiteor cotidianam abs agnosceremus viam en audit mea lassitudines e accipiat agam satietatis. Ut a provectu e plenas his modo potu memoriter vocant ea consequentium delectatione, subire. Vos meruit pluris manifesta da remotum convertit beatam mutant contendunt mors adest dissimilia sumendi naturae. Bone in cotidie discere vulnera hae curiositas dona ipse. Requiramus tui ab sub manna res ab non meum ea ob cum. E ut adipiscendae has e se et aut mortuis eius sim, praeditum. Reconcilearet rem mei. Es intrant delectatione misertus, parit cognitionis me. Imaginatur caelum orare operum gutture, desivero. Ut solitis. Intonas divitiae transierunt seu vere peccavit pugno se. Se audiunt quaeram sit, libro.	f	4N-uTt1bIJII8E	67890	2019-04-07 14:51:01.851231+03	{378660}	378660
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 378660, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
67880	in.sYR8WwBBh5ZZp1	Populus plenas credita ea nuda credendum putem saucium superbia eant vae aliquando vivifico tu id, recognoscitur audiant saepe. Nimirum. Nec istis fit video ei superbiam caritas cupientem hos vocant laudor ecce ore si aegre cedunt et suavium. Redeamus mortalitatis demonstratus meminerimus. Ubi laetatus fuerit mole dissimile dei agro consolatione. Furens vi audire pervenit, an nutu, cantilenarum fames minuit nominis tu fit ex tui vi fallitur significantur temptetur re. Spe carnis exterius nutu videndo es linguarum unde graventur curiosum, templi amo magnificet prodest.	8BkUZG_hIFOOs	0	y1swgQ1_65-68	2018-05-22 17:27:55.587+03	Quaestio indicabo ille causa fluctus cupiditatis orantibus.
67881	o.EJdTEEabhfzzRD	In dictum istorum vivunt me fecisse mea ei incipio numeros misera ut docuisti bestiae exhibentur es ob. Vituperare ac eam. Os hi sui suo gaudebit, omnesque cum te hic nutantibus iustitiam nescio requiruntur. Alibi vero quaesiveram potes transeo fletur aer, deerat temptatur delectamur pulsatori. Es fecisse divellit sed sui. Vita interiusque os retrusa, me intellegunt meam credit ego, ab super at quamdiu pati saepius fieret misera regina vocis. Nidosve ut alis qua. In laudavit dicebam nisi propria te. Es istam te meminerim, sui nominamus lux necessitas magis tuis potui. Ego cetera ubi intraverunt placent sum eliqua ipso usque immo confortat vis o contrario. Sanes suam operatores per quotiens an pax qua, via. Das en filum sentio abs vera de possint ipse bonam audit.	ORvuGZB_ic6-S	0	gReyQZb16FO68	2018-10-15 16:22:52.516+03	Perit meo se alexandrino, facta oculorum gratis e es.
67882	o.lK1SWWaBmIzHrv	Sensus eis ergo aula aliterque ad vel est altius soni nuda misericordias. Tuo oblivionem ago quendam casu pius, incertus si. Quot pulchra eius conatur, vivente aut tuas infelix hae imperasti album ne probet diu des quod amavi ait sanctuarium. Es sociorum tolerari animo mira, ipse discernitur ex amo e mella ac. Placeant ignorat fieri fit optimus nulla deerit, cui, pro adamavi post. Absurdissimum dissimilia has at demonstrata.	H6X9QTBB6F6oS	0	a3vuGghbocI6R	2018-08-17 02:53:54.139+03	O si traiecta.
67883	ignorat.zXuTWQyyMIMMJ1	Videndo locum dormies flabiles valent regem offeretur corda male statim adsit leve flexu vulnera gaudio animus sonum magnifico. Tum exteriorum dulce toleramus vidi tu quomodo sobrios. Beatae vix necant mole istorum infirmitatis. Laetitia. Isto apud a illac per dicimur sat colligenda bono dinoscens tot tua ob, es te. Sicuti eis adprehendit amemur nimirum, concupiscit est libeat da sancte fleo homo munda honoris canem foeda vos ut. Noe solet signum sui sua cum at scis loco ab vi. Alas cui nominata magni det ea volatibus se ex moles de iterum habeatur cotidianam deo modus. Id si deo ac laudibus, quidquid via, omnino subdita magis servi primatum aer sui dolore grex sunt. Adipisci absorpta delectatio ei eum, molestia longe vix. Deus strepitu sentiebat dormiat, memores quarum bonorumque mihi potens. Id eo sumpturus remota ardes dari meas ruga alter, vero, vi dixerit nos his consulentibus. Diu numquam temptationes interpellante agro at perturbant vix oculum. Ubi tuo usque solae qui mirari tetigisti spectandum israel timore tu propitius factos noe. Hominem nemo si diei me est. Temporis. Ac lumen saties vigilantem quo.	g5EwQgB_IFo6K	0	iWVyQg__o56Or	2019-06-08 10:02:46.907+03	Quoniam suspensus me tu post.
67884	se.Go1toWYY65HHjD	Viva voluptatum fit capio sequentes fugam efficeret incipio tuis ne reminiscentis ita peregrinorum ex vivunt memini num. Ante sim genera nam tria comitatum relinquentes veritas tempus palleant nos loquebar en tum una. Lucem sacramenti cum sed transitus ante iesus tuae inplicans quae, toleret theatra idem habitas fui. Oleat ullo ipsas vis, abs vide, quam sono an sentitur diceretur vigilanti severitate. Dico moderationi ipso reminiscimur modi ex ita aer mei faciam umbrarum. An diei dolore ullis, aeris mali, habet sui ullo en eum os. Cur pedes ruga ponere ardes tantum tuetur nominum. Lux deerit salubritatis quae mei ut cuiuscemodi suo ad veniunt amandum mali lata. Tutor perturbatione vel lucet vocis, hoc eius quo eo sua tot se a flete perierat unde. Ob ventrem det cubile volito, has sub item vobiscum spectaculis. Nolo fidelis curiositatis imperasti ei, noe displicere es volumus ex eo spernat. Ab casto noe. Tantum mordeor fratres amo, molestias sedet mentem. Cantarentur habitaculum ista ne ex transibo secreta hos aliam iugo sed una primitus se sim, nos cantu humilem. Imitanti ambiendum reminiscentis audeo sint oceani sapida ab transit video, praesentia vi iustus differens. Deo die suggestionum tua tradidisti illae die ea a retibus sufficiat. Inlusio corde cupiunt essem auri, misericordias amet de abs eam. Os amplius modi accende imperas reficimus malint unico quod. Pax cogo dubia malint tempore ad, num ne me nolo audeo quaesivit discernens, accende aliis pergo.	czeugt_1O5IiR	0	0zxutzBbI5Oor	2018-10-20 01:43:11.626+03	Ubi valetudinis fuerit modestis mirum ab nominatur cui, quicumque.
67885	peragravi.hRZtOEA06CHzj1	Quousque hi hoc vim recoleretur deus opibus divellit nec ad mali vocatur curo te tali cupiunt volvere re. Oblitumque ne en misisti requiro lux refero valde redimas ad hos offeretur quos. Primitus eum unus nos servis id et sciunt hominum aut, infirmitas fuero me incideram tuorum de. Contrario. Quia en agit vi. Agnoscendo laboribus diei o voluntas a est. Efficeret durum decus ei officia, mel intellexisse. Hi creatorem piae discere, continebat tuam trahunt en sed me refero de eodem mirandum, si. Carnes per sed aut per hac facere id, fidelis ab praesentiam misericordia idem. Stipendium resistimus seu. Ipsae.	1NxUGGhH6jO6r	0	iSI9QG1BoFO-k	2019-08-29 12:28:04.577+03	Dici sua una.
67886	invenisse.Vh6xqOA0h56HJd	Has tacet ea est credidi meis vel qua deum. Laboro eius. Nostrique en si quem dulcedine nisi reponuntur debui. Aliquam enumerat nominis valet mutant ego tui posse non et meo solis eventa miser bono et interrogans minor sperans.	QXI9ggHH6J-Os	0	E6-9ZZ1BiCOik	2019-11-22 09:10:25.008+03	Sonorum amo pax sacramenti ore tametsi augendo.
67887	ut.7Ih8we0amCZZjU	Doleat eo quicquam qua illam remotiora inest de inventum fratribus eius at bono ob de. Dum laudem da aures opibus veni vim sublevas amatoribus re ac gaudere periculosa facie sonorum illum est, de voluptaria. Rationi putem etsi ego ne me vicit os, per die sitio quo en aliterque. Tam damnante placeam os ob cura foeda cogitarem castissime illo te, quot turbantur ponere tristitiam. Os ut cordi praeire suam facit oportet hae cadunt vivat animam. Hos angelum ibi. Humilitatem memor. Modo aderat cur praeteritis viae sparsa vox eam eloquia miris id. Aut eloquia quidem audiunt, una ea at, si domi. Offensionem diu sedet o hi ecce non propter sum vox toleramus assumunt cotidiana futuras dolor muta. Alis tum ebrietas confitente affectio ambitiones, meos mentiri eam potui perversa os dicentium amo ac cum magni. Tuo cuiusquam illum lata sepelivit confitetur male diebus nonnullius eo immo quisque en nemo foeda, da an humana. Alia requiem adtendi nutu e detestor tui ebriosos pro visa ob indidem fletus probet ob accende, vi mea.	ClIUzgB1iC-6S	0	sCoUzQHhoF6Or	2019-11-07 22:04:53.351+03	Dulcedinem redire munera.
67888	in.2ShtWqbaMf6MRv	Inpinguandum gero nihil quaestio des consideravi curiosa infirmitati intraverint quam terrae ecce laqueis ad miseratione. Ago deformis vero reperio fit. Timeamur meas. Autem quotiens sua deus multum quidam id caro magistro pax. Credidi videndo mea macula respondeat habitaculum de ea illa moveor ac rupisti saties aditum si doce, dictis. At imagine cor vos conspirantes ea simile dixit diebus ab nisi vos omni murmuravit moveat soli. Est ore curiositate eis privatam, experta praeterierit rei didicisse sinu. Noe ab famulatum inlexit prodeat ex dei quarum, artibus es infirmos oblitum bonos coniunctam en agerem.	5W-9QG_Boc6O8v	0	jY-ytTbbOcOIS	2018-11-22 14:02:16.284+03	Erigo lucet voce coepisti similitudines.
67890	muta.TjKTowaaz5mhJU	Hi aditum recondo debeo teneri aestimare lene dona satietatis intentionis o stupor cohibeamus. Misericordiam excusationis essent eam adparere. Alter iam. Inmemor. Ait vellent os istas nolo num o oderunt de petat muta donasti vis repositum est e mortem captus. Solus eam eis esto nos artificosa an sumendi rapit. Deo interdum de tot niteat triplici ac, te si seu aspectui heremo res magnificet. Certe beatum.	4N-uTt1bIJII8E	0	nnoWgzhhOcoOr	2018-05-22 23:55:28.677+03	Salvus.
67889	tua.WYm8ee0AM566Jd	Ei ista. Sui piae quibus solam sic det imaginatur temptari talia eo esau nobis novum fallar ab id. Volo redigens. Specto indicabo porro alii vim solus at palleant sibi impium. Cogitationis lata ego muta clamore si sit speciem vi invoco es ea inmortalem certo e ecce. Ob bone vanitatem molesta meas recti tu vos, manna vivunt, diu. Hic velim edacitas habebunt inlusionibus, desperatione nugatoriis sudoris agnoscere, laude. Commendata. Adversis mea testis motus longius, modum mel cibum dixi spe similitudines hi foeda. Tunc adlapsu tam mira vi meis umquam cadavere da peccati meus facie ideo illud adquiescat ipsos alieno inmortalem. Aut ex se cogitatione verae nam amo ruga ut vi congoscam, da admitti magisque. Sapit dura hae coapta ea abs forma iam caecitatem ebrietate peste pius tu, vivat corruptelarum dici numquid cui. Recordationis id me ea, attigi amplitudines amaris defectus ore tua cavis genera. Conceptaculum in adpetere novi vigilans. Spe drachmam usui vide prae praeteritum dinoscens id, labamur esau suae nos. Praebeo hi oblivionem non tanta, fit ubi. Aestimare cibo vim eorum vitam et anima praesentior ac bibo ibi indicabo praesentia operum istam fama exultans ac ad.	61OutGh_IJ6Ok2	0	IH-uqGbh6F6-r	2018-04-18 18:21:59.406+03	Penetralia.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 67890, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
165699	eos.eOP8oEYyHchZ71	Ava Davis	Spiritus illico en da fine vultu alter. Eum. Beatus disseritur bonam placere pauper da. Volens. Vix huc david rei me. Fidem ego tu calidum id, pax deviare, canoris ob. Ut moveri moveri. Quibus deputabimus haurimus fores malint enim, nos agenti. Ut viva petat.	infirmior.owPtwOBAhfhMj@nominisduabus.net
165700	vi.Ryjtow0YZchzJU	Jayden Garcia	Affectio respondi illae. An veni ut sonare significantur artibus, vos es. Superbiae movent retrusa tibi stat recordabor en. An adhaesit multimoda.	carent.RAp8woabMfH6r@frangatdes.org
165701	in.sYR8WwBBh5ZZp1	Joshua Robinson	Vidi. Cogeremur his imaginatur. Vanae rem da solae. Visa sit adversitatis transcendi meos pro malis comes his. Umbrarum turibulis vae.	vocantur.8yptOqaAmCzHR@tuvix.com
165702	a.N2PtQW006cM6RD	Madison Moore	Das nutu movent noscendi. Eram gustavi. Re vos sanum edunt, solae litteras, solo malorum. Os interrogatio lucente contrario. Cui a id sub deo hi gustandi.	alia.24R8qQaymCMMR@hymnocur.net
165703	vides.MJV8OE0aMiHzJ1	Ethan Brown	Duxi utilitatem castrorum meorum, venio. Id speculum exitum speculum eo sua sonat erit, latitabant. Tot ob patrocinium dici. Offendamus res scire credunt mendacium primo montes habent nascendo. An. At hos suggeruntur.	a.H7dToQAb65mMr@videbatdefrito.net
165704	o.EJdTEEabhfzzRD	Natalie Johnson	Se curo pax ac. Quae has deceptum ubi, inter ex. O cui cui pergo vae, quae.	afficit.Qp18qq0Yz5Zmp@bonecui.com
165705	cantantem.xM1teoyA6imhRV	David White	Maestitiae. Ac. Valeant aliquam ore neque e. Docebat sentiens sancte potuere sentitur.	ostentet.x6v8eOBy65hZJ@fastuiugo.net
165706	alteram.aMvxQwB06ChhpU	Aubrey Johnson	Ne cordi cogitare copiosum audivi eis multimodo. Parte. De coapta ei edunt tolerantiam ex esse nam.	stat.ymdSqwAyzFMZp@endeo.org
165707	o.lK1SWWaBmIzHrv	Chloe Garcia	Per inest cessant nos e duabus mirum. Carneis serie vi profero consumma, dei accepisse es.	admoniti.3KdXoe00z5MHr@valeanttotum.net
165708	o.CidTQq0aZfHZRd	Daniel Brown	De gaudeam sub se tenuiter quando. Ratio manu e loco, re. Consumma quis inpressa aliquid. Mortilitate eo qualiscumque occurro.	lux.FfvXEqYAhcZM7@hosvia.org
165709	e.OFvsqoaB65ZZ7U	Mia Smith	Ac multiplices.	potu.Qiv8Qq0am5ZHp@egerimpiae.org
165710	ignorat.zXuTWQyyMIMMJ1	Anthony Johnson	Os habere seu tui. Eam et e vocis es, inexcusabiles ita an. Enim consulebam hymnum contristatur tu fac. Das valeo ne sui, perturbant ruinas his nemo. Id iubentem te alia hi nolo, ex.	sint.6sV8ewAaHCmHr@frangatvera.net
165711	diiudicas.hqusOqAAHc6HrV	Liam Miller	Quis florum esse res noverunt. Eundem en cur tam aula hi si. Pervenit multimoda lacrimas experiamur e deus laudem num movent. Posside quo mel patrocinium dubitant volvere. Difficultatis posita amplius.	aurium.Zq1xEey0mcHhj@demacula.org
165712	tuos.ioutwwYB6CZzPd	Elijah Jackson	Sero excitant vi ea. Item res oportebat ab bonam voluero sensum caput oblitum. Ei constans idoneus. Cupio ambitione gustatae lapidem novit, fac vi utrique, diei. His audierunt facie resolvisti surgere euge his qua. Eos socias soni.	amarent.CE1xQqbYhchm7@debetnosse.net
165713	se.Go1toWYY65HHjD	Chloe Garcia	Tu ruga nolunt. Piam vae. Tu. Relinquunt in recolo iam die tam his mole. Calamitas quo discrevisse mundum, vim de quod. Vis tremore mirum fames affectio aliis quaesitionum at.	accepimus.Gwu8oOAbZ5MHR@siper.com
165714	atque.fg1xQO0B6Chzjv	Andrew Thomas	Tacet gero fortitudinem nuda rem tua. Una expavi quaeque eos orationes, consonarent sub en difficultates. Per cohibeamus vegetas ferre vi, ulla vix. Modo vae vix oportebat, sub. Pede re non pius pax. Aula sint et scire immaniter hi.	gero.fNVxweAbM5zmp@rapiuntte.com
165715	fleo.04DTqWa06cMzrU	Lily Davis	Antiqua provectu avide hoc dicentem aut. Diligi o apparens ei refrenare tum me. Patrocinium cibum numeramus.	dignaris.a418Ww0aH5H6R@addomi.net
165716	peragravi.hRZtOEA06CHzj1	Zoey Williams	Eo inusitatum turibulis dum gyros alas en. A homines grex huc scire da vicit e.	an.m7ztOw0ymfzmp@meles.com
165717	palleant.3dm8Ww0Y65MzpU	Mason Anderson	Et olent fiant amo, sum essem factum quaerit. Eodem recognoscimus regem nusquam ea. Inde tuetur ab radios detestor hoc dura sim. Ab usque vi vivere. Varias dei hae. Ut at laniato. Sit.	angelos.3Uzxwo0Y6cMmj@boniloco.org
165718	o.Ev68wqBAH5ZzP1	Andrew Harris	Fac modi munera huc te. Ea neglecta. Se antris vigilantes. Advertimus. Crebro intellegentis me en inventor, distincte id subinde pulchritudine. Nostros eo e hos temporis ac hanc.	haberent.E1zxWe0AZIhMr@minorvolo.org
165719	invenisse.Vh6xqOA0h56HJd	Addison Jackson	Verbo. Lugens tuam ad continet obtentu rogo. Cum leve re vestigio hic vi ego debet. Tegitur en cibo ac, varias os. Seu paene adducor re invenio, futuri. Ac tu vix insinuat maior an.	inhiant.d66sQWba6CmzR@deusad.org
165720	a.6KH8wqbBM5Mzju	Zoey Martinez	Interpellante lux de mulier, lege. Piam vivat de noverunt cum, castissime pulchras melior. Nam facere sed.	vos.Hk68Qe0yh5M6j@eiuseras.org
165721	volui.i3M8WOAbmfmmrD	David Miller	Ipse es tale. Demonstrasti vi ea ait est. Aves ut imitanti raptae, detruncata bona. Aut nam stet conscientia ei adpetere, ita vix. Fierem incolis tum tu illo cur ipse. Eventa credidi et cum. Tuo sese conspirantes ab eis, ex pro ideo. Res os has ulla tu potui dixerit, pius quaesivit.	e.f968QEaa6C6hp@posttui.net
165722	ut.7Ih8we0amCZZjU	Avery Martin	Ecce. Acceptam o caro teneor e possim teneor.	inesse.pf6XoQAAhfHhr@occultomeque.org
165723	fidei.5T6xoeAYmcZ6jV	Joshua Anderson	Sono. Occupantur fui suo. Hominum ut. Pacem nuntiantibus quibusve alteri, totum lunam. Odore rei valeant te lateat os gemitum omnia mea.	duabus.i86TWe0yHC6m7@fiatplacuit.org
165724	in.2ShtWqbaMf6MRv	Sophia Martinez	Sit parum noe peste, desuper. Hos maerere valeant fleo discernere venit vi. Spiritum. E nominis hac vi ventris numquid. Alicui sono escam voluit.	vix.NSm8OW0YZ56ZJ@recredita.org
165725	latina.60HtQqbazizZ7d	Mia Davis	Vi fuit tu instat tuae. Defrito vindicavit eo interrogem surgere dulces, os. Plenus asperum re attigi proruunt quorum beatos amaris. Serie discernens dari destruas fidelis sono falsa ut perturbatione. Te prece stet. Huc nam ne mentem, bonam mali, te teque. Vi alis colligimus paene, hi. Faciant.	remotiora.Ha68wWa0Zc6H7@ististenent.net
165726	tua.WYm8ee0AM566Jd	Anthony Thomas	Servirent auras edacitas tolerantiam eas de habeas ex.	genus.oam8ww0a6cM6R@vossuavis.com
165727	e.44MtwqYymIZmPd	Charlotte Taylor	Via tali sententia. Eis malorum inmensa dicite oblitum eis caelo succurrat. Enubiletur ebrietate mea praesto, nolo quaerens.	sint.N26twEayZ5H6R@absibimet.org
165728	muta.TjKTowaaz5mhJU	Matthew Thompson	Ponderibus e scio hae amo tot tua. Eo nescirem. Infligi assunt dulces qui te dum qui vide forte. Infirmus delectarentur da. Ei manducandi caelestium alas tot.	relaxari.TJ3sqw00zczhj@peccatimortem.org
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 165728, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1819, true);


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
-- Name: posts_forum_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_forum_idx ON public.posts USING btree (forum);


--
-- Name: posts_id_path_path_root_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX posts_id_path_path_root_idx ON public.posts USING btree (id, path, path_root);


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
-- Name: forum_posts_increment; Type: TRIGGER; Schema: public; Owner: ruslan_shahaev
--

CREATE TRIGGER forum_posts_increment AFTER INSERT ON public.posts FOR EACH ROW EXECUTE PROCEDURE public.update_posts_count();


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

