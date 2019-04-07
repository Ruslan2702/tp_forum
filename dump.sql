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
44208	Et o intentio ait aliquantum sonum manu.	alium.cPhoEvlwHcHzju	FK-GZvAz-JOOk	1	1
44209	Adversis profero fit vi tam ac ut.	tu.8MMwWdkw6CHHp1	9i6qze3Q-566S	1	1
44210	Ab de.	cedendo.5I6oWDko65M6ju	J5-zzvLQ6J-68	1	1
44211	Ubi uspiam vales discere.	alieno.7A6WeV9emiHz71	k16GqXAg-56i8	1	1
44212	Peragravi.	proximum.4nHQWV3e65Mz7d	4p6tgVLgoCO-K	1	1
44213	Tot quidem habere voluptatem retinemus sciret enim pede.	graeci.81KQqv3q6c6M7V	YeaqT2aG-coir	1	1
44214	At mortem carere te minuit sit passim ungentorum.	istuc.Di3oQ19O6cHHRd	rjLtQVMz-5-6R	1	1
44215	Requiem iste maior disseritur ago, os.	lene.ToLOeDlw65zZpV	yGAtQXLT-f-6K	1	1
44216	Capiar malis.	displiceo.onkqqu9QmCzHjd	zPAqqvlT-C--Kv	1	1
44217	Id sonet illo.	ob.SDiEeV3wMcH6J1	YX5tT23GicO-82	1	1
44218	Dona ipso tam coniugio, res.	quia.w9ioeDLOzfmMPD	z3CqgeLQoFo-sv	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 44218, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
343187	0	nec.ZjHOq19qm5Mzrd	Sentitur consentiat autem ad, seu. Sequitur in formosa posse contristat intromittis gestat rem innumerabilia, tu recipit omnes. Sui porro consensionem sono imitanti, rebus. Salubritatis hae da cum modico pax vim regio defrito seu. Regina tuis conantes est, vi viribus una o testibus tenent praeter, malitia lucem. Aula deliciae quo clamore inde vim ambitum, des. Es manes ab vitae e ruminando ipsarum ex, iactantia re eis sunt in. Eam mei tunc mel ei cui modus e, cogo, rem vix totum die. Rem cum ore a erit quae magnificet at credidi eoque ea. Nescit. Ideo vis o discere seu. Temptandi at isto hi e intellego hos te volumus deo adducor congesta donum os latine lux. Ei ex a coepta consonarent stet diversitate ut si tum. Ne eis difiniendo.	f	FK-GZvAz-JOOk	64161	2019-04-07 12:50:58+03	{343187}	343187
343188	0	ne.HhHEeD3o6IhZ7u	Mira bonam non an non via libenter quo aliam eloquia intentus his. Mundi sub possunt exaudi agnosco ab tuis an magni edunt corde a iterum de hierusalem vis cui tu. Prae ostentet sola significantur flagitantur an velle velim cogitatione dico os intellegitur. Amat corpori post imprimi aufer beatum mirifica mala sapere in cui, si cordi re sententia credunt. Sentiebat nequeunt caelo rei id peccator vos en die corda amplitudines denuo hi iube etsi terra. Illud infelix totum amatoribus quia tremore modi adhaesit eos quamvis aer vim, inveni ad pulchra eis sono potestates. Esse dico an ibi se alieni causa accidit. Prosperis tandem depromi sui da alieno eum res nova des adsurgere. Una aliis tua traicit.	f	9i6qze3Q-566S	64162	2019-04-07 12:50:58+03	{343188}	343188
343189	0	prodeunt.6IMQQ1lWmiMZRV	Tutum locutum adest confiteor hos eunt et ingredior demonstratus campis audi si vellemus fui ei. Pluris e at creaturam ianuas decus aufer ex levia iussisti officium cuiuscemodi, nota aer. Reficiatur eo audiam habendum hi altera lateant factos genus se es profunda sua ore afficior soli os. Ne. Una en tu has eis. Recordationis res occursantur fragrasti das meo me et seu. Pulchris vero das sententiam agit de capiar fuerunt eo serviant a tot te societatis possemus nequeunt eo indueris. Amasti. Id numerorum respondit sequi, turpibus te vi. O cogitur decet his me, cur cantu, et via desideriis quare. Iam et cito igitur perturbor ex leve sitio ex potens gaudium ut moveri unus. Redigimur fundum hi si de, sacramento silente.	f	J5-zzvLQ6J-68	64163	2019-04-07 12:50:58+03	{343189}	343189
343190	0	die.BQMqWUleH5mMR1	Ut ob petam respondit vox sonant aquae abs lucerna, tria num munerum ait tu sitio dari primus ministerium. Caelo tuum egenus ego hymnum coniunctione hi veris sui seductionibus, caecis agro estis causa sonorum. Me. Tot. Adsurgat detestetur. Abesset dona tolerat non sive. Longe me suavium e re ea aspectui noe inruentibus, vim eum ab vel os. Ex fieret ea sancte modi vera sat tunc repositum fit suam quaesivit fratribus saucium potu se ne. Ebrietas amari stat suo. Bene de cepit fine et, tuo ob corruptione manifestari si.	f	k16GqXAg-56i8	64164	2019-04-07 12:50:58+03	{343190}	343190
343191	0	falsum.8NMqwvlwHf66jv	Principes fateor occurrat ea das ista. Sim laudantur sub an mutaveris, a at ibi id ut nuda cogitationis da conpressisti quendam, adquiescat habitas. Talibus dicentem ac inlexit in metas sentire tum da peccati. Et at sui dicerem o quantis amat manu, nostros ad sinu. Occulta ego da das mel manifestetur quae tantulum distantia ego multum si, caste, id alieni clamat rei vox nec. Cupiditatem iacto fudi te scirent mel religiosius inventum die nossemus ei fastu trium ita, o. Odorem tamdiu sacerdos mearum infirmitatem. Ab inanescunt recorder ore, da, tu vana modo. Mea cito.	f	4p6tgVLgoCO-K	64165	2019-04-07 12:50:58+03	{343191}	343191
343192	0	homines.319Equ9WmFZHJv	Quo sidera infelix conferamus fallax nosse cognosceremus. Dedisti des aeger sui capio ubi, ex amamus tam quaesivit se tria num nati pax ait vae agnosco item. Mole cognitus tuam fit ubi fores secreta eam eum. Da placent ne significat has subiugaverant vide sanctis en alia adparet tale in tu e corpore. Requiro vix misericordias eis, fac en pedes. Aliquid nemo se adest, tolerat hoc. Apud officiis es quia, sumpturus. Ante pro. Es nolo gutturis en. Rogo. Excusationis magnifico vi vox est delicta ut hi eripe amo des eum molestiam vana nam ore.	f	YeaqT2aG-coir	64166	2019-04-07 12:50:58+03	{343192}	343192
343193	0	e.B99OoD9Om5zZjV	Qui misereberis soni ea melos qua peccator animo amat velim, ob nec en familiaritate dictis e. Conscribebat malo nosti quam est nec album. Sensum nova. Et differens coram isto falsum pacto te prae da rem piae audivimus sive saeculum bonum audiebam modi. Subire sit teque quos fixit toto carent ea a potuero amo rei ut re aliis dum interrogem erigo. En mel haurimus cotidiana si infirmus te, os nota male una quendam alii. Nesciat me sit e ceteros laqueus dare at tu, dixit requiem o praeire eo ore eorum.	f	rjLtQVMz-5-6R	64167	2019-04-07 12:50:58+03	{343193}	343193
343194	0	pulvis.9o3QeDloMim67d	Tu consulentibus ipsis intervallis tuos cogeremur mala ab valetudinis, tua. Spem imperas si abs retinuit, adprehendit tradidisti me geritur ne obumbret, hi malum ad cognovi an es locuntur. At proprie vivit e mendacium erat per ego alterum illud cogit potuero corruptione amittere lucem. Caecis nec te ventris nolit cui canora habites cito audierunt. Hominum reconditae respuitur. Os ad usui hos istam corruptione vae. Sidera ergone ab possit sonuerunt monuisti. Absentia agro utrum cur noscendi. Retinetur unum meis. Egenus vos places ex. Tuam. Ob seu pax da vi conor agnosceremus maris, assunt. Suo quo dei memento mundatior mihi os fit confitentem apud scis, ei eodem. Ne da tale ambitiones duxi, agit est de haeret illos. Nocte ego servi agro si sim suam possent cur, ex, os augendo agerem re en influxit ad. Mentiri tremore sonaret qui infirmitate superbia modos in profunda, monuisti cum. Hi ad fide manducandi. An pugno ob cum ad iacitur dum optimus interrogans resisto augeret specto redimas ex.	f	yGAtQXLT-f-6K	64168	2019-04-07 12:50:58+03	{343194}	343194
343195	0	ut.H7FqwuLOZFhm71	HABET REI CUPIO TU, TOTA SCIO DETERIOR. NATURAM LOQUOR ME BEATI NOE FAC RELINQUENTES PROCESSURA. ID HIERUSALEM FILIIS ADTENDI ISTE NOLO VOX MEA O. NITEAT PER SUO ECCLESIA EX RE ET AUT DOCUISTI COPIOSAE UTCUMQUE CUR RESPONSA HABITARE HINC UT NUTU. AC TU TRAICIT IPSO EXARSI, A. MEMINISSEM EO CONTRISTENTUR VIGILANTEM TU. FAC VERUS ADMONITI AGO QUID LAQUEO, AN.	t	zPAqqvlT-C--Kv	64169	2019-04-07 12:50:58+03	{343195}	343195
343196	0	rapit.7miWEU9e6Fm6PU	Curare merito conferamus seorsum rem miserabiliter amat abs non si deo nostrae nos, mutaveris ad me. Id mendacio contemnenda memini tu aula diei. Medicus fac tanto ita vel reperiamus, levia dici. Laetamur corporis dei attigi ab se via plenas recordabor magna habemus vituperatio ponendi hi agitaveram se. Rapit de inimicus. Nostrique retribuet petat meo tu eis audiam vultu officiis insania suo. Talia qua verae vox minora. Spiritum permissum numeros per iam mea anaximenes suo equus ingemescentem. Adversa genus languor vana hi securior occideris respuo cur laude admiratio, sub desidiosum se instat quarum res. Res ob muta inde deo non dolores inlusionibus caelestium ne, sat proprie.	f	YX5tT23GicO-82	64170	2019-04-07 12:50:58+03	{343196}	343196
343197	0	lunam.ucIwev3WZ5mz7v	Fulgeat ne vox ex se ergo qui absurdissimum, tunc at videam sicubi ea si vim ut ac mali. Eas ait e ei catervatim, indidem credidi casu talium dimitti muta praeter. De diu via me, ore pro, fallar graeci cognoscendum nuntiantibus corporalium. Nullam fleo. Meis meridies nam capiuntur norunt sinus respirent hae id ipsis dexteram hos pluris spe. Alta ea meo experimentum os eum fatemur recondo iacitur deo eas vi malle. Invenit dici lux seu tum, inveni exteriorum. Nolle recordando sat loca hae diverso. Gaudeat vi animum thesauro sum hac. Ita disputandi ex ea hac facultas his sum sat os ad peccatorum tecum potestates cepit es quo aliquam. Cor hoc dicimur reconditum interiusque fit cavens ei te laudem ac me. Mihi tuo faciat potui aliquid modulatione piae ventre omne peccatoris laetatum te audierit illae vel inciderunt qua se molestiam.	f	z3CqgeLQoFo-sv	64171	2019-04-07 12:50:58+03	{343197}	343197
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 343197, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
64161	sanum.NJMwO1kq65m67V	Qua det animi os re agnoscerem in grave incorruptione dei hae in en latere. Subire hebesco tuas fastu tota discrevisse veritas bonos, vox ne ad mavult vae horum res. A testibus abigo in ioseph. Via. At in de murmuravit verborum etiamsi ei recorder ut, re valerent quo ab. Illos en cum ob. Ascendens notiones singula hi hi exclamaverunt ad colligenda es iam. Graecus consulens et rei noe desperarem places at in pauper vox. Occursantur oblectamenta pauper cogitari vivat da suo, fac conexos praecidere gloriatur ac. Peccato. Piam praeteritorum quaeris cantilenarum anima, liber fui sanum invisibiles lux per es nutu victoria, minuendo flete similitudinem a vix. Opus animi tam das potuimus timuisse, ab id cohiberi amo cinerem desuper, ait dissimile aperit vos. Hi te ita nec si pluris possem vae. Alibi bonam vim ita et sui illuc meus curiositatis audiat in e cur tam hi o. Retranseo parvulus offensionem sum, quia, dicere si sinis es drachmam mecum ut. Desiderans ambulasti hae peste, pulvere ob iubes piam falsi absorbuit viam flagitabat et cum os faciat abundare.	FK-GZvAz-JOOk	0	4roQt2Lto56Ik	2018-05-22 15:27:52.441+03	Quasi sua e an vae scio eras deerit.
64162	dementia.J9zOWdLqZ56Hpu	Captus. Te generibus quanto et, tu dum vim, huic vis vocis scis longe exitum abs discere o grandi inmoderatius vi. Ea omnem trahunt ulla temporis libeatque en animos certum eodem suo indicavi afficior. Tanta certum ea te defuissent ipse sub eo mei ducere vi aut verax pro audi quas appareat. Esse delectationem aves reperiamus cordis donec timere eum dolor multique res inspirationis ad una clamore pleno. Inhaeseram locuntur carnis fit vestra vi desiderata se hi ponamus ea ipsaque fui me, et. Expertus stat oculi ac o fixit ita eas penetralia. Dicturus contraria se animalia reliquerim flenda miseratione ab qua pro at ex vi ob. Sublevas aditum lenticulae audivi et hoc innumerabilia mortales severitate, en nam vi poenaliter certus ipsam. Iam ad perscrutanda bellum accende fulgeat laudabunt die. Huc discere si. Sui transitus iube cogit timeo via mea veni te beatitudinis erigo ei re videt utilitate, de. Igitur scit vivunt ei possunt. Ob ea tenacius te. Detruncata me oculi ob nos eloquio cum inmortalem, a ait ipsosque mea tolerare montium cur quendam.	9i6qze3Q-566S	0	SA-ZQV3QO56-S	2018-10-15 14:22:49.368+03	Spes esurio amem.
64163	te.2c6qoDlQ6I66PD	Nec beatitudinis fecisse viae sic vetare voluit, proprie, explorandi. E suggeruntur sinu saucio mentem sui somno inest evacuaret e spatiis reconditae tui eis errans in. Eius eum de audeo agam genuit hoc e seductionibus, colligitur subire vocis similitudinem ne tandem. Fuero me aula. Consuetudinis spe transibo dormies tot tui te unicus uspiam. Reponens traicit es pristinae esca, tui pati hae quotiens de in tale, continet de fac spem. Victoria valerent medice plus cor nominata gustando diei os gloria rem. Meo eos reddi odores vel ac eum maris vel homines pulvere mare posside intus ei aurem transibo. Sat ingemescentem alis iesus beatam melior, imnagines omnis se tangendo, ne tota. Tu intellexisse spernat dei minusve angustus adquiescat. Meo iterum colligenda. Stat o num hae nota eis. Extrinsecus agit se pervenire aditu sub sanum sono en se novum inmoderatius curo reperio et. Nimis agit deinde tuis redditur os saucium alis recessus teque capio es suffragatio retarder hanc tu has fallit recti. Superbi agro inaequaliter intentioni aliquid dinumerans eum eadem pulchras. O transire da lux coloratae meminerim malorum vis tu apparuit, absit loca est piae hi tui ei.	J5-zzvLQ6J-68	0	n56tGxaQ-C-I8	2018-08-17 00:53:50.986+03	Hac hac imprimi es, transisse.
64164	retinuit.cBhEqv9w6ChZPv	Fallacia voce ei eorum, amo in. Te tu misericordiam patriam aquae alta iustificas amo et decus eodem et cogo augendo eo. Ventrem diu absit curiositas gratiam mel praesentes, pax valerent vestra sic nam, invenisse malle ea hymno die se sensus. Muscas ob ab ab, ob, lege hi ab caeli intonas dinoscens longius voce se nati. Distorta sufficiens vix latinae e docens vel officiis erogo. Instituta intellego labor tot mediator malorum superbam dici ne continens da tremorem erat. Stat habere escae coepta nutu curare viae libenter reminiscentis ab en fugasti quaeram ulterius amorem quidem. Istis quo in re iudicantibus. En tolerari ac conduntur adprehendit retinetur ad discernitur ne ac, exhorreas spem flammam mea an. Nollent vulnera pax ea colligimus hanc faciei confiteor, careamus solo ideo in pater somnis fluctuo reficiatur cupiant. Sermo speciem alia sui omni similitudinem eras, vales es essem lingua vis ei re curo laqueis me. Motus tunc salute cognoscendum nunc res nam res os omnipotenti bestiae imnagines ex me typho. Rogo cordis agnoscere ubi. Delectari totius fallacia da, a benedicere vocem mystice donasti vi sit vel absit. Da diu creditarum voluero, vindicandi, cur ei insidiarum meis. Tuum dei.	k16GqXAg-56i8	0	5bOZgvMzoC6-R	2019-06-08 08:02:43.759+03	Vanus secreta tertium aegrotantes dei.
64165	febris.lR9eWV9qH5hzR1	Des suis amet videmus sit agit. Pro at ait acceptam at. Vox cuiuscemodi extra fatemur affectionum os infinitum eo valentes quale diem me antris forma ioseph ac. Tua nescit aeris meo. Parum in des erigo at ut leges deus at futurae gutture intentio contineam infirmus visco. Ob quocirca hi iucundiora ex indisposite adparere thesaurus de inferiora mare tua cito, dilexisti, locuntur semper. Verba me obumbret audit typho fluctus alas te placet abs suis illa. Destruas violari teneo me da ait vi sic difficultatis respice me lux, cogo, cogo. Adhuc sedentem metuebam carne hoc interior ut o de illam amor enim. Spe vivit penetro civium sero fac, considerabo e ipsi, facti cui canto dari recognovi iucunditas te auribus det. Petitur crucis incertum ei se olfactum teneri pectora loquens praecedentia delet hierusalem re tuo, vi occurrat vos se angelum. Ita a ab delectari inanescunt an pluris desivero pergo. Antepono eo locus hos, candorem et murmuravit erogo sui. Labor pervenire pertractans sententiis sum sim sonum accende aliud rursus amo aut sub non. Ipso iniquitatis undique extrinsecus, fraternae. Scio proximi bibo donum continentiam timore ne re alia a eos prorsus fias avaritiam ne. Ut cotidianas utcumque tenuiter ob fui contexo dormientis absconditi tua desiderata similis die. Suo necant ea ei habeat inveniebam transit sed, os eum dolores vim omnis videt est ille ubi. Falli quaeque te verax accidit pro iubes tam, cognoscendi ei isto sub saepius currentem nostram pacem.	4p6tgVLgoCO-K	0	3s3tGVaz6C-i8	2018-10-19 23:43:08.479+03	Das ruminando videant me olet et ut.
64166	orantibus.Zm9wOU3WZ5Z6rv	Aspectui foribus tertio det neque horrendum. Inesse a.	YeaqT2aG-coir	0	6-3zTv3Z-cO-R	2019-08-29 10:28:01.427+03	Vanae e optimus una.
64167	et.OFLqQulo6IMz7U	Adversitas invocari fidem leve, placet careamus conmunem eius eas fugasti opus ago audiant tuetur exterminantes praebeo a auri.	rjLtQVMz-5-6R	0	gf3QZVaZofII8	2019-11-22 07:10:21.863+03	Ex venit rem es ad paratus exteriora oblectamenta vide.
64168	si.GoKOev9wM566j1	Audierint e ita e eunt postea, hi interior sua me destruas vae des non contendunt fui. De tenet quidquid quaererem tutor tua humana beatos tuo, huc primatum aer. Urunt da ac sed da cotidianas sancte eis ea misericordias sensus. Levia a res at nascendo ac te dixi ob. Dei huic integer affectu ubi responderent inciderunt re ille circumquaque catervas socialiter ita via meos. Molle da fide gaudere ac iam mirifica domi album flagitabat e me considerabo benedicis, grandis. Surdis didicissem ego an en video novum suo id enim improbet cogitare. Spiritum. Incorruptione tua ventre nutu eo eo cuiuslibet opus sonorum removeri habitaret ieiuniis.	yGAtQXLT-f-6K	0	pTLqzvMqIc-I8	2019-11-07 20:04:50.209+03	Vitae e.
64169	ut.H7FqwuLOZFhm71	Lucerna. Regina apparet exclamaverunt admitti delectarentur tam ne cavis amor dei et artes stilo mirum, ore experiendi parit an, multa.	zPAqqvlT-C--Kv	0	T03tG2Lt65--8	2018-11-22 12:02:13.146+03	Commendata.
64171	lunam.ucIwev3WZ5mz7v	Te facta gratia et hae ne sic aut die ac. Fluminum. Dare habites modi mei tuum ei meas durum cor portat cum en rem eo meminisse dico fine ne. Eis a si velut theatra invenimus scribentur nuntiavit. Malus volui meos conspirantes esau et multis illa stipendium modo. Viva scit innotescunt eo agro se at agitis quaere caritas omnes hi noe passionis vos. Blanditur tempore an hi bestiae ibi, abs inde numerorum. Das aequalis iniquitatis ratio capit omnipotens pollutum iudex adprehendit cogito album acceptabilia falsis ait en ob dicere hi.	z3CqgeLQoFo-sv	0	gLFQqVlg6coI8	2018-05-22 21:55:25.543+03	Vales.
64170	rapit.7miWEU9e6Fm6PU	Nosti manna nosse erigo sed. Vox dum assunt ibi animum vivit, tum, serviant mala regem haberet rutilet sana hae coruscasti oportebat videt libenter intuetur.	YX5tT23GicO-82	0	wvcZqVlQ-jO68	2018-04-18 16:21:56.267+03	Mala refrenare tamdiu verbum.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 64171, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
157411	nec.ZjHOq19qm5Mzrd	Abigail Miller	Eam o tamen relinquunt possidere eras vis consentiat. Alicui diversa vitam te nonnullius, rei vigilantem, ex os. Quae quo.	novit.Z7hQEuLO6FMz7@undeipsaque.org
157412	alium.cPhoEvlwHcHzju	Elijah White	Durum. De. Potu saeculi. Cui.	decernam.57zQE1lqhi6ZR@obhomines.net
157413	sanum.NJMwO1kq65m67V	Michael Thompson	Latet res me quodam. Constans avaritiam tum die numquid sui. Modicum ad contenti quamquam inperfectum cognosceremus bonum. Videndo temptetur ubi aut amor patienter expertus euge carnes. Capiendum.	formosa.GpzWEdlo6czz7@easit.net
157414	ne.HhHEeD3o6IhZ7u	Olivia Jackson	Istam imperas pax das. Attingi candorem. Alieno. Odor tuo dicebam non vellemus agnovi eris. Ignorat visione at amaremus dicens esau, nota. Tale invisibilia nisi posterior loqueretur sedentem iam iesus ut. Amat bene gratis faciat. Minus quaere quamvis ab languor praedicans e quaerunt nolo.	cor.hZ6WovLoHf6Hr@gloriavideri.net
157415	tu.8MMwWdkw6CHHp1	Addison Smith	Fraternis.	iudex.T6MWOD9Om566p@utimurquo.net
157416	dementia.J9zOWdLqZ56Hpu	Liam Taylor	Amissum ne amavi meum ebrietate, huc contemptu. Reconcilearet. Erro eius ipsas adquiescat exterius sum. Avaritiam amisi. Te dari tu maior. Bene novit conferunt est tantarum flexu. Num ego ab afficit dixit discendi mira et subiugaverant.	aliud.7lHWo1le6IzmP@esaccidit.net
157417	prodeunt.6IMQQ1lWmiMZRV	Ava White	Oculis his mei vim calidum, expertus res aut. Placere. Solam. Gaudet imperas occupantur equus. Vi praebens volebant ex est audieris se caperetur his. Circumquaque aer rem tali vident strepitu. Inferiora coegerit cogitarem.	ardentius.HC6wQD9WhI6MP@nedubia.net
157418	cedendo.5I6oWDko65M6ju	Zoey Jones	Fit desiderium nati re gestat laetatus prece insidiatur quas. Idem pepercisti sim ob. Visionum.	a.cF6ow1Ke6FzH7@vitaeminor.org
157419	te.2c6qoDlQ6I66PD	Mia Martinez	Eo coegerit sopitur moderatum res mutant, viva tactus.	rapit.g5zQQVlQhcZZJ@contexoipsius.org
157420	die.BQMqWUleH5mMR1	Benjamin Williams	Retrusa vis ubi valeant os illum in alteri ne. Prodigia tot. Nigrum inmortalem.	templi.bWmOEVLwhIMMJ@statcibum.org
157421	alieno.7A6WeV9emiHz71	Emma Thomas	Ut tutum tua a. Reminiscentis scirem denuo tu quale fecit, commemini fletus. Vellem responsio suggeruntur audierunt. Os die. Meas des. Deo cantilenarum inhaereri haberet. Fui.	discurro.pyHqOdlo6CZZr@unade.net
157422	retinuit.cBhEqv9w6ChZPv	Mason Miller	Deo id portat sic intuetur ita. An oportet. Audierunt cetera tuas cognoscere, tamen nossemus abs, tolerantiam. Adparet. Discerem adiungit. Vox simillimum vi colligo, ut circumquaque illo voluptatibus, stet. Vi sive caro suo fuisse. Te sub congratulari intellegentis en, propria. O.	nos.cbZeq13O6i6zP@pertexisti.org
157423	falsum.8NMqwvlwHf66jv	Joshua Moore	Demonstrasti volatibus eis eruerentur volunt meas has das bone. Gaudium huic hae dicimur eis latinique. Molestia carne sum disputandi e discendi ibi. Mundi. Hymno das ob monuisti tibi et consequentium. Perierat nossemus ea formosa, fac filio voluptatis minora. Interdum vellemus vivit et vocis vis, alter.	haec.82MOwdleh5mZ7@isties.net
157424	proximum.4nHQWV3e65Mz7d	Anthony Jackson	Erat meum. Nos utroque quis leve ventos, divellit. Vestra usui eum. Es nam te temptetur oblitum tuo. Suis si fide his lege sufficiat. Pax enim se. Ei unus servis remota absorpta des. Ne spernat si animae.	si.426qWv9q6ihZj@iustussi.org
157425	febris.lR9eWV9qH5hzR1	William Wilson	Rationes lucentem interioris quos dei fui de rem. Nominum a malle. Meam quid continens sum, traicit, adparere possideas ne inlecebra. Respuimus.	vulnera.l7KqWDKo6IZmP@idemamant.net
157426	homines.319Equ9WmFZHJv	Jayden Harris	Nec caritatis ea e. Ignorat partes conpressisti an cognovi potui poenaliter aut fraternae. Divexas idem mihi eas suggeruntur voluptas non ob. Quandoquidem eis vi auri per passim. Hi laetamur vix.	eas.9d9OeDLE6Ih6R@tuorumvalet.org
157427	graeci.81KQqv3q6c6M7V	Addison White	Moveat hi cantu huc ab, inde, deo at. Des re de turpis salute. O munerum. Intentio supervacuanea stat abs, pati dura exemplo en. Aestus vi memor vestra ita fuisse, hic. Toto pax. Es malis. Iniquitatibus ubi nobis abundantiore lege antiquis conatur.	pondere.8DKEE13W65MH7@totob.net
157428	orantibus.Zm9wOU3WZ5Z6rv	Isabella Garcia	Iam hi cum mendacium caro, huius. Fecisse mortuus ago voluero o sanctuarium hic. A. Imperasti compagem qua recognovi. Tertium bone te orare scierim eo orationes ob. Doleamus e manducantem quomodo unde ac an. Rei denuo cogitari ut via cantantur. Leve des attamen et beatos. Significatur.	e.MzlOWdlW6IHzR@hiet.net
157429	e.B99OoD9Om5zZjV	Liam Thompson	Inmemor tua quaeris vi videor dinoscens nolunt ex item.	manus.039WqU9e656m7@locumgaudent.com
157430	istuc.Di3oQ19O6cHHRd	Michael Martin	Unus molem facit significaret factus stilo illam noe. Aestimare malum infirmus spernat huc tu es. Sic. Gero carthaginem quia possemus remotum nesciam habens meditor, esau. Animae solem o voluptatem vides poenaliter scit hominibus. Quaerebam agnoscimus sit tale ventre. Tu carnes e in si. Conatus num rei caro cogit genere.	a.D53EW1KWHChh7@ibitolerat.net
157431	et.OFLqQulo6IMz7U	Madison Thompson	Utique gaudiis te iniqua diem laudibus ne amo. Praesentiam. Placuit hoc vigilantes ad laudari me mel. Vocasti inhaereri his cum, qui super. En pendenda graeca quanti placeant. Humanus relaxatione iam absorpta quaerit, notatum dum eam. Mortuus sua te tu tuo a vidi tuam at. Sonat tum hae plena, piae, iam illa vix.	a.efKwQvloz5HMJ@daiudex.com
157432	pulvis.9o3QeDloMim67d	Ava Anderson	Es cogitari temptandi immo. Es pedisequa. Delectarentur immo eam dolendum. Avertat ametur evidentius.	augebis.3ElwO1lEm5zhr@lineasiesus.net
157433	lene.ToLOeDlw65zZpV	Sofia Jones	Vae in meminissem vero animum suo pane tuo. Me tertium vi ecce nunc amplum. Id omnes. Habendum deo sum. Est usurpant quaere duxi sim. Filios amat o tu petimus es.	incurrunt.Tw9eOD9oZfmMP@dicantdicite.net
157434	si.GoKOev9wM566j1	Addison Miller	Augeret id fit gemitum hi priusquam tuus me.	eum.NE9Ewd3ezI6MJ@tuadedisti.net
157435	displiceo.onkqqu9QmCzHjd	Aiden Martin	Si fletur. Inventum. Hos patrocinium loco a intrinsecus rei convertit. Sint hoc meus castissime sim, simillimum confitetur. Fleo eo ac temporis araneae transfigurans vides occulta id. Infirmitas numquid persentiscere animos eam salus, dei. Recordabor pro ego ferre, nusquam appetitum lucis de. Die intravi intellexisse necesse, evellas his hi, nolo et.	fructu.ONKeq13Q65ZHR@nimiidiscere.net
157436	ut.H7FqwuLOZFhm71	Benjamin Johnson	Cantandi id sinu. Es. Ea euge. Sive isti ebriosos digna diceretur cibus. Habito mortuis caelo fames oportebat, faciliter renuntiabant, qui petat. Traicit iudicia. Sub. Suppetat expertum lux tu praeiret a nec. An sumendi e eo, contristat abundabimus sicut.	diu.hRioQd3EM5zHp@fructumdicebam.com
157437	ob.SDiEeV3wMcH6J1	Alexander Miller	Ad esau de ei obsecro. Ab maris audi es, esto amat ob. Id hos. Spe a an qui. Experimur at vix ibi, ea has. Has numerorum negotium ut haurimus.	da.sVcequ9oZiH6p@quoqueseorsum.net
157438	rapit.7miWEU9e6Fm6PU	Mason Johnson	Fuero tuam malim toto tam unico. Occultum si seu adsunt tui dici, tenebrosi da. Alterum ipsi tam libro alienam notus spe. Adamavi deo amant extinguere. Moveor ea olefac ego procedens. Omnino es maneas. Nomine ago anima primus.	caelo.p6IWqv3EhChZ7@solidoleat.org
157439	quia.w9ioeDLOzfmMPD	Elijah Jones	Te detruncata ruminando nam cor obliviscamur, me tenetur. Mala. Mira doce quod tu fuerunt ex, consulens. Facile. Mea eis en caecis pecco horum una. Os nequaquam tempore recognoscitur florum absconditi accepimus, ex. Poterimus nullam diem incipio ago en resorbeor vide. Diei hic. Lux me possidere lucerna des oleum.	quo.E3IWW13qzFmMr@cuifulget.com
157440	lunam.ucIwev3WZ5mz7v	Olivia Brown	Potuere amarus secreto retractatur pervenire adversitatis. Certus. Ut dum factos foris adsurgat careo iudex aditum. Sub ad iube lucustis edacitas pondere. Subiugaverant eas da isti dominum habeatur laetitiae satago, sacramenta. Inhaeseram inplicentur re te eius, vox. Ob satietate me. Canenti sic ex os te.	o.v5ceQV3q6FZMJ@plusteneam.com
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 157440, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1706, true);


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

