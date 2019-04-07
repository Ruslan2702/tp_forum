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
44625	Grave sua nihil viae sonet, lingua.	propositi.US0ZkfbwmCzzjD	vWh6LFHZIjo6K	1	1
44626	Velint e palleant una an.	ducere.P00m95AQhFHM7u	r_H-Lf_Z6CI-k	1	1
44627	Doce lata ob curiositas.	proprios.pjnZ35boHIZ6RV	k8p-Lf_t65Oo8	1	1
44628	Hos filio.	ea.Q64zLFyQm56Z7v	Z-0-AchQif-o8	1	1
44629	Os vera iudicia fugasti, gratiarum me.	volito.XcnZl50WZ5Z6PU	wFN-LFHt6f-o8	1	1
44630	Vi nam repleo etsi quendam tempore hac.	exhorreas.NWnhkI0OZ56hpu	pG4o3FBto5oir	1	1
44631	Vox penetralia cuius.	insidiis.wN26LiyO6I6ZPu	t0P63ChZ6JO6S	1	1
44632	Seu tu colligantur scirent.	alieni.zhr3LcaqMf6M7v	OikLa51Q6F668	1	1
44633	Diu.	contra.09pKLcAq6C6MJv	1asaajbtoJio8X	1	1
44634	Hic diei.	ea.Ts793fyo6IzZ7v	WYKAAC1QI5-isv	1	1
44635	Lux.	vox.mapKk50EzCZh7U	-bsl3cHg6ji-8e	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 44635, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
348901	0	respondes.bc06lfyWZcmzpD	Notatum. Vim noe cum. Animant praesidens rei usui imitanti agam es ad vim spargant explorant servitutem confiteri hae hi tacite motus. Consulunt refugio gaudent ad diem, spe. Abiciam tenebatur eo dicat ne gaudii inmemor penuriam. Sapor ei olet oculo diversa ex commune quandoquidem, ac valet prosperitatis interrogans approbat simus cibum audiar quam hoc ebriosos. Es vos ne prospera refulges spe typho ad ut vivit tibi me sub o. Id ambitiones. Vi nemo tametsi oculus fuerim quandam. Consuetudinem omni omnium multiplicitas cotidie videns in iesus tot. Gavisum tu tribuere totum falsissime. Quippe actiones e suo, pro quaeris. Illae quiescente tot vim experiamur hi surgam in se tum.	f	vWh6LFHZIjo6K	64736	2019-04-07 13:28:59+03	{348901}	348901
348902	0	fiat.AqaZ9caE6iM67u	Velut hymno religione agro. Vel teneat. Diu. Re se ineffabiles intellegimus foris illam. Fratribus placet cogo elati te tamen erant. Ei ac saeculi tua se en suavia oris num tua. Quattuor vim pars victoriam simus facit vi una a delector vivant. Die hi in metuimus sapida tristis sonis sed aut audierunt in sonis. Psalmi. Item da lux. Inpinguandum habitaculum in dum. Omni ullis sana hac fac. Mei me nesciebam re requies vix lux palliata, ob cognoscendum innocentia. Quaeque hac volui scio sola inest nota tale faciente agam tu possideas videtur, istas sedentem ad diversitate. Fieret quare te ab iste languores hos nisi velit rogo ex mediatorem indicatae amicum es. Imprimitur invenirem ore ducere iube datur agro habeas at suppetat hic. Qua ac potuero uterque transeatur si mei si. Nota das illis cum habites aer sua deerat dicis affectus nulla ea, explorandi ascendens videre resistis sed, laudabunt. In rei tui.	f	r_H-Lf_Z6CI-k	64737	2019-04-07 13:28:59+03	{348902}	348902
348903	0	diei.qGyH9IBemiMzR1	Utcumque campos separatum sim servis antiqua, corporalis amplum ulterius huiuscemodi meo, aquae iumenti dubia servis animales praeibat. Eo. Didicissem manna docebat tundentes dei fide te tu fluctus caeli ab canto e. Enim aer avertit tenent tua vita. Lene meam varias sacramento pax ab ait non domine olet dominaris placet contineam commemini hanc, superbiae nimii ego quidam. Humilem sensarum cui unum oblectamenta ad canto reminiscerer necant grex adversus se muta ab aestimare. Ingemescentem iugo lux sim, pro videri gemitu omnium auris fac, gavisum serviendo experiamur. Ruga fiat gaudet absconditi in iam tua meae de at pedes, consuetudinem. Et at exemplo deo flatus id nolit viva rem esca os a gaudeam regem cognovi. Issac meque das alias mali genere laboribus aboleatur auribus id non placere, mea laudibus cito. Anima grave servientes amo flete, saturantur sentire. An me. Primus peragravi sidera confessiones, amorem. Vis aut vox a vivant vi en solus eis spe eo, sancte docuisti omnesque. Ex hac murmuravit invenisse maeroribus se quam tantulum adlapsu distincte da, da copiarum. Sitis id ex.	f	k8p-Lf_t65Oo8	64738	2019-04-07 13:28:59+03	{348903}	348903
348904	0	convinci.Im463fyEh56zjV	Tot medice curo et. Metuimus.	f	Z-0-AchQif-o8	64739	2019-04-07 13:28:59+03	{348904}	348904
348905	0	fit.hf263iAqmFMZju	Potui da unde digni odium eo an orantibus pars laetatus dominum misera diligit lugens, eas vix mutans mediatorem. Ne alii hac rem tu cor inmortalem eum, defluximus gero prius voluero o ita via. Eam. Transitu. Dicant praestat iam ac, inhaereri fabricatae idem, ita. Domi hae. Hac se qua amaris os afuerit verus invocari an ob membra consequentium non eas stat re isto fecisti vi. A fac et ob. Amplum macula lucentem cupiunt ad cum o eunt cui cuiuslibet. Tu humilem nidosve ubi cum ex an curam ubi eos positus eripe mutant misericordiam montes nominum cibum es metum. Scierim valet at ipsos sedem cur iniquitatibus.	f	wFN-LFHt6f-o8	64740	2019-04-07 13:28:59+03	{348905}	348905
348906	0	has.eW4zLIaOZIh6J1	Diu evelles te meditor. Curiosum sub montes ceteros o eo si inaequaliter siderum generatimque. Vis veni si hi consulentibus cubile ad abstinentia abs abs exteriora tum an te intime.	f	pG4o3FBto5oir	64741	2019-04-07 13:28:59+03	{348906}	348906
348907	0	doleamus.fnnm3I0EzChZj1	Videns ne meum stilo a caelum spes tuum. Ob tua e sic ob fuero ut.	f	t0P63ChZ6JO6S	64742	2019-04-07 13:28:59+03	{348907}	348907
348908	0	vanias.oU7l350EhcHHr1	Universus nuntiantibus rei mei. Alibi da invisibiles facio an an, petam una redimas, manu se pro vulnera es nosse eas ab. Ea displicens meque manum, ad meae ei fastu num, alis. Requiro non bonam det sat ac meae, hi officium. Sed subinde. Eloquio pietatis nescio ac, ita graecae, manifestari et ulla audit ob eis. Fit longe si verbo plenariam te inplicaverant interrogare pluris si da se, imaginis iube vox re cinerem, deviare aerumnosum. Videtur re oris. Admiratio datur a si, est sat re eo ut primitus recuperatae. Ac vel molestum et fuerit suo.	f	OikLa51Q6F668	64743	2019-04-07 13:28:59+03	{348908}	348908
348909	0	tundentes.mc7L3fBwHC6M71	HUC SPARSIS EOS CONOR NOS MALLEM VASIS IMAGINATUR. DORMIENTI. SUO. ARDES NEC MUTA TUUM RES PARVA AMO FACTUS VIX FATEOR. MUTANT A VULT CUI AUT DIU GREX BEATAM TANGUNT GENUIT OBSECRO NULLO SCIERIM HUC ERAM NUM SE TIMENT EX. NUMQUAM AMARITUDO PERIT CIBUM SIT AGRO VETARE NON SECURA, EX NIHIL COR, CERTUS FECIT NOMINATUR PEPERCISTI. COR PARATUS OS.	t	1asaajbtoJio8X	64744	2019-04-07 13:28:59+03	{348909}	348909
348910	0	det.VeR3L50EZiHMR1	Diu sacramenta manducare. Scis ex ac meo e se es en contristatur olefac ibi at magistro remisisti, tuo athanasio hi una.	f	WYKAAC1QI5-isv	64745	2019-04-07 13:28:59+03	{348910}	348910
348911	0	vis.8A79LC0WMi6ZrV	Spes recedimus laqueo bona fac vae sapit possideas fac si si haeret alio temptatum dei. Ipsum. Huc servis esto euge, die pax aquilone en contractando erigo medice ita istarum tu grandis vel ago. Recordando patitur praeciperet ineffabiles, aliis fallitur a, egerim. Tu vel laudare sim es canora cui amo qua alicui ore. Pius miles hic dignitatibus leporem doce totius hac deserens illo os sectantur me. Tangendo os sciunt ab dei hi ut meo rem num meminerim huius aurem me recordationis misericordiam. Des munera ob homines via temptari es. Videant tribuis hi propria carent vim tua iam toto adflatu careamus defluximus. Hac quos explorandi faciem caritas spargant ex abiciendum consuevit turbantur optimus aer, seu ob luminoso conscientia sonum fac. Mundatior abigo caelestium ioseph, heremo hac dicite caeli cito silentio disputandi iam mirabilia potius veluti conectitur aliquantum. Spe da tam. Hae das virtus omni modi datur sacramenta contemnat ne. Da offensionem aeger pecora, sententiis in erigo vocant die instituta.	f	-bsl3cHg6ji-8e	64746	2019-04-07 13:28:59+03	{348911}	348911
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 348911, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
64736	naturae.QT0HlFyWZF6M71	Dignaris eos cui episcopo multi inmemor minister volumus ait adhaesit spatiis rutilet eam. Eas alius parva offeretur vituperari in item praeteritis tu ubique id ago aut ago, tuo aequo a hic aqua. O ex aut tale videant. Oportere pro inesse. Conantes inludi minuit. Me de rem aequalis nares me fletus procedunt. Erit evellere direxi vi oluerunt an os hoc fudi. Afuerit. Naturae fuisse retibus nescit in molle ibi misericordias audivimus de profero locum propitius vigilans dulcedine. Reminiscentis ea cum eo, tu, experiendi surditatem mea. Hi. En interfui tum quisquis post alta ab latis vim possideri, doleat seu at, cor immaniter ad amo operum. Refulges digna etiamne vidi hoc sat tota da die tu sua. Una aures posside id en cernimus an destruas. Cupiant avertit earum nemo stellas peccatoris sic sapores gustandi manu abs ipsi. Digna redigimur fac corruptelarum venter, tu des e secum tam est his, at diversa ista escae.	vWh6LFHZIjo6K	0	zwHiLJ_TiCI6k	2018-05-22 16:05:53.2+03	Mel ea fiat vox at nostrae, mulus eos adversus.
64737	id.sab6l5aQ6I6hr1	Reddatur exsecror o fidelis multis sonos en beata cupiditate, unum. Edacitas dolet fundum miser vis recondens errans sive vi cui. Eruuntur interpellante. Tu iohannem illi. Te das silente amavi, meus blanditur convinci optimus perit alias inaequaliter ambulent. Sapit victor saluti verae aeris ei eloquia e id desiderata leges vox dura sciunt putem piae das, peccatorum et. Praeteritam omne ut vestra cellis his, secura. Vegetas ob primus nosse temptatione, tua dum. Dari piae vivit loquebar os abigo malus illi misericors bona ad re os a o nigrum aliae suo. Cantu donec deo illis eius sunt. Ita requiramus sat nimis o ea vegetas suae muscas durum dixit sua responsa, nemo num, simulque. Viventis. Inde odium quousque meminimus placere, sanabis vi ait meritis enumerat mirifica in se vegetas ametur. Est praesentia gaudii potestates.	r_H-Lf_Z6CI-k	0	WHbOAcbG-JiOr	2018-10-15 15:00:50.126+03	Tuum fecit vi ait tuum.
64738	sint.iP2Z3faWhC6zJV	Ipse arrogantis unde res e tenetur praebeo, visionum miles tot alicui fac. Mulier. Stat cur ut rem laudem ipsa inmensa, dei laboribus.	k8p-Lf_t65Oo8	0	CkPIm5bg-C--8	2018-08-17 01:31:51.744+03	Mirificum ruga tenetur ipsa quantum.
64739	a.vkN6950EzF66pd	Cuncta futuri spe ei muta adhuc eum sinu. Disputante da excogitanda qua, carentes occulto ob te. Des deputabimus ventre si ambitum viae significantur eos redditur dari ei vellent. Lumen re corporalis. Severitate sit iubens peccatum in, vult ita rem veni vindicavit delectarentur mel ex ipsaque. Escas possideri se tui, expavi eo. Locus canoris sobrios a. Ipsas munda me nam dicatur. Suam immo tuo passionum, timore. Mirifica a nuda spe, et pleno. Est es tum res, da eant secreta contexo ubi, manifestet pro eas. Hi. Dicis ponamus nesciat nos nec donec praeire ac. Agro si sicut omnipotens, sonet norunt imitanti nitidos mors ex doctrinae resolvisti posside nec parva. Si cum optimus fudi insaniam rem ago sua quaerentes a abigo cum faciebat ita tu places, o responsa pecco. Tui sedet etiam cur os, tali paulatim diligit vae tanta fama.	Z-0-AchQif-o8	0	v34-aCHzICI6R	2019-06-08 08:40:44.518+03	Noscendique o perficiatur obsonii hos os tundentes tua.
64740	saeculum.VxN6kFYwHIMzPd	Hac os amat munda recordationem sub tu debeo e, ne abs me exserentes. Futurae amo ea oculi nam dolor id verax ac voluisti recognoscitur, ab orantibus volumus frequentatur. Imagines ad da. Suspirent me me quae maneas si. Nepotibus retibus coepta una o sobrios gustandi, o in. Desidiosum dicere o canitur ungentorum ab fit, amplum occurrit. Amandum varia evellas olfactum audierunt bone vox multum faciendo. Simile detestetur una finis deliciae. Nimis valde sapiat ac quarum illuc toleret at refrenare. Bonorumque discurro aer sui cum vae aenigmate sanctae flumina o stipendium periculo et abditioribus aut quid. Ut traicit ipso. De re sat inexcusabiles meo deo quos. Rebus praeciditur rei aspero remotum se. Omnipotens ullo a vos potestatem infirmior.	wFN-LFHt6f-o8	0	2w0-3f1G-Jook	2018-10-20 00:21:09.24+03	Reponuntur sensus vi numquam.
64741	fructu.30g6l5BEMI66j1	Vae sacramenti percurro homo imples vix constrictione ab hi meae spe da e eo. Videtur. Adsurgere abs vix hae se tot facile una subinde libidine aestimem delectatio facultas, o freni de multum tutor vi. Verax alas dextera valeant res adsurgere te docentem innotescunt ea amplior soni foris ad se cum. Ut quot tangendo abditis inperturbata. Sentire tot sim. Benedicis iustum similitudinem ubi vivere propositi, dicuntur re rem pecco amasti. Adsunt cordibus velint aliis dilabuntur iussisti inconsummatus secura fores hic o pars propterea ascendens nihilo os cantus supra agitaveram. Nimii diiudico sonet metuebam fac doleamus eum da pars angelum, auram fac vae teneat ei habendum cellis. Ad ea exterminantes vel ut ea meae coepisti quot nugatoriis modos ad equus palleant ratio operatores scierim augendo.	pG4o3FBto5oir	0	A10-AjHGOJ66k	2019-08-29 11:06:02.19+03	Mare piam sint.
64742	e.hjP3950W6fH6pu	Ecclesia imperas conor an alta privatam crapula cupiditate manet diei assuescere da speculum pius occulto da, offensionem re maestitiae. Sim absconderem en erat vana te, eras. Hic. Timent interior modus disseritur locum, soni, vis. Id munda fastu cantantur. Capio novi diu se retribuet ab tria in artes tuos illi. Clamat delectationem defenditur variis meus, alio. Mira da tenebris. Laudem absurdissimum lumen ascendens possent, ordinatorem ac aenigmate ea. Audivimus cura uterque quidem, deum erat. Tenent en copiosae male de agro, piam aut quousque. Tuam canem. Parvulus persequi absconderem laetamur teneam malim quo ipsi proponatur mortalis cor das exterius. At dicat psalmi interdum bibo possim salute. En odoratus infirmus instituta sum relaxatione curiositatis integer pietatis fallere turpis. Vellent o.	t0P63ChZ6JO6S	0	6krL3fBt-C-oR	2019-11-22 07:48:22.621+03	At servi iaceat remisisti, ut.
64743	e.pkp33FyOZ5hZjV	En hac hi videre oportebat calumnientur sive terra nominum bibo grex salutem cervicem. Timore meas munda omnipotens custodis viribus meridies ea cogitationis res eo aranea sed, ullo nam. Da pro expetuntur una, alias hilarescit. Vero faciliter es latissimos domine seu, norunt at dei subiugaverant invenimus. Cepit ad cantu praetoria temptationis sequi tum inmunditiam et obruitur qua itaque facti obliti, iniquitatibus. Vi eo essent coruscasti item expavi eis me usque vox quo fulget tamen cantantem cui aditum fit ea ea. Fecisse sic sinus radiavit ipsi e spatiis inest se mittere recondi hic qua erat variando ob propria exitum. Intrant genuit palliata cogitari te, sensus secum. Num contractando contrahit. Vidi nulla ei tenacius concessisti in hoc filio me insaniam quae admoniti artibus desideravit tuis dei en ea. Scit erant pluris e a a qui lata intellegimus et en os ut. Sedentem signa isto an. Sui sibimet hi quem immensa tot clauditur et campos ait unus loco distantia invidentes.	OikLa51Q6F668	0	R3rML5_Q-5-6S	2019-11-07 20:42:50.971+03	Fallit vim cogo considerabo his.
64744	tundentes.mc7L3fBwHC6M71	Molestiam attigi. Sarcina an dari cotidianas eum huc repetamus interroges. Fac propter altius placet. Dolor significantur huc retibus ita aliae recti quantum vi aqua fac quamdiu. Id hanc soli ad iugo tetigi eo an suam fit, eam. A sacerdos. Hi intrant fac mendacium dei ei hac bone. Pervenit ei se teneant ea dicerem id tu casu es cura re gaudere inruebam nollem. Sola conduntur amittere datur. Subiugaverant te ergo recordarer expertus intraverunt, edendi rei oculorum.	1asaajbtoJio8X	0	Ha8MLj1toji6s	2018-11-22 12:40:13.899+03	Item e da en penetro unde, hae tu meo.
64745	det.VeR3L50EZiHMR1	Subire absorbui desuper mare, o me. Pacto quousque simul humilitatem viam hi, lucis a. Album assuescunt valent decernam.	WYKAAC1QI5-isv	0	UUKMA51gIcOiK	2018-04-18 16:59:57.02+03	Sat perpetret.
64746	vis.8A79LC0WMi6ZrV	Da teneri contremunt typho ea. Res decet id prodest, mel consequentium cur satietate hoc ac mentiri. Mirari has ita similitudinem. Commune. Melos turpibus an tradidisti a unde sic da meae meminimus, prorsus. Lassitudines praegravatis sic. An mors inplicaverant o nulla reprehensum mala spargant ei, tristitia caecis inimicus abditis os e. Delectarentur istis ille spem lucerna, bone se abyssus cor audis. Consortium tot vult et et alias bene instat, o amor pulchris hae loqueretur os mors. Te quaero malo sat nimia si qui a eo vos, labamur me adversis nam ducere agit tantum aliter. Dum honoris fieri de ei, dum hic de perfusus, eis ut potuere. Pati ob agro his intravi quaeritur mella agam quam fulgeat si recti iam tui nam tua.	-bsl3cHg6ji-8e	0	61rMmf1QOciOk	2018-05-22 22:33:26.292+03	Delectati deteriore.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 64746, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
158694	respondes.bc06lfyWZcmzpD	Zoey Martinez	Ex sicuti tum da. Stellas pati ante retinetur eos, peste, sui. Meditor cor. Ingredior. Stet. Prosperitatis artificiosas salus. Dixit narro ad viae vix sic.	o.aFAMliBoHfM67@amarentnimirum.net
158695	propositi.US0ZkfbwmCzzjD	Noah Davis	Numerorum has lege cor quadam. Medium paucis reddatur quo, ei spe. Vim ea ad cogit eo tot id aeger. Tui foribus det propositi has et vales. Vel o primus nuntios ac corpora habes fuero. Ordinatorem hoc id mordeor nepotibus habitas meo dominus. Visco habemus.	terra.18a6KcYwMImHP@tenumquid.net
158696	naturae.QT0HlFyWZF6M71	Jayden Thomas	Os curiositate ibi res utilitate inest, solet pax, recedimus. Defrito apud respondeat posside istam seu generis.	leguntur.qSbmkCBezf6hp@remdum.com
158697	fiat.AqaZ9caE6iM67u	Noah Robinson	Visione ad remisisti patienter priusquam cadavere ab hi vi. Eam consilium at me noe capio. Amo. Hac eadem posco de delectatio. Hae meditor iam eo tam. Fuit ne.	vicit.yWYZ95AEM5MZj@luxipsam.com
158698	ducere.P00m95AQhFHM7u	Sofia Anderson	Me iniuste aures tali capio quamdiu. Vel niteat vox cum tantarum.	notatum.pBA6kIYQhfhMp@potuerevix.org
158699	id.sab6l5aQ6I6hr1	Alexander Robinson	Eum turibulis in diversa opertis iam a ut en. Os. Mel alicui infinitum. Ante latinique angustus constrictione oblitus videmus invenit. An. Eo ac ne. Vere societatis spe miserabiliter res noe ad, ei aula.	reficimus.XB0m3CyEHcmhP@piaeac.org
158700	diei.qGyH9IBemiMzR1	Matthew Thomas	Pro. Inhaesero dicam e meus, parvus sumus es laetandis quam. David audire die. Qua te qua. Copiarum vos ceterarumque hic ei. Peccato alio eis omnino beatam, petitur auris certum invoco. Fastu tu huc.	tum.WgYhliAEm5mZR@stuporex.com
158701	proprios.pjnZ35boHIZ6RV	Anthony Smith	Minuit ut pede eas eos rideat, eis. Eo gaudiis tuo quattuor.	lux.7j26KCaQz5Hh7@amicumatque.net
158702	sint.iP2Z3faWhC6zJV	Joseph Williams	Oportet.	os.fJNMlFboHI6zR@tesuper.org
158703	convinci.Im463fyEh56zjV	Ethan Johnson	Graece.	dare.Iz4Ml5Yqm56H7@oderuntquia.net
158704	ea.Q64zLFyQm56Z7v	Matthew Martin	Insaniam hanc optare. A ex locus. Cui pertractans e illa videam contemnenda, repositi vident cur. Spem es hi pars vos pusilla. Aegrotantes vocibus escas hi places adamavi, molem vales. Donec reconciliare eos sobrios occurrit id aula at. Creator at accende es. Et. Et fulget decet ne minister nescirem.	cito.wMnhkCAOhiZHr@mereturcredita.net
158705	a.vkN6950EzF66pd	William Smith	Colligenda. Vituperari auri et. Defectus hoc perfundens si assumunt contra at languores. Utimur fit visco recordationem. Mei exterminantes praestat peregrinorum sacrifico, venio, castam quaerentes. Visione ibi. Hoc tui. Tuo vox modico de eo solem, meis noe. Rem.	a.v9G695YWZFmMp@alitermeae.com
158706	fit.hf263iAqmFMZju	Abigail Garcia	Sic flendae. Se ex. Pristinae sacramenti amor nescio os sustinere eos non humilem.	falsi.6in63iyWZF6HR@viserro.net
158707	volito.XcnZl50WZ5Z6PU	Aubrey Anderson	Ne ibi olfactum avertat. Eruens. Illa. Abs ne avertit bonis. Meis quare. Hac eo eruuntur e, se mala cum praecedentium. Ei.	delectat.854H9Fyo6c667@erigosub.net
158708	saeculum.VxN6kFYwHIMzPd	Matthew Thompson	Interiusque dubia te bonorumque suo malo ago.	possent.V82zLfyq6i6hP@memorianimis.org
158709	has.eW4zLIaOZIh6J1	Andrew Garcia	Scribentur metumve aut humilibus interiora obsonii ipsam ob.	vidi.wo4ZliAQMimZJ@itasim.org
158710	exhorreas.NWnhkI0OZ56hpu	Sophia Robinson	Ago. Velut munere salus aestus securior videmus, ob. Una es certus de potu est. Ut. Utroque sub.	pristinae.nOg63CBOmcm6p@ennescio.org
158711	fructu.30g6l5BEMI66j1	Jacob Garcia	Rem. Extraneus. Te ibi. Potui nova ab servis vivere sit vocant improbet diverso.	tuo.Ly2m3I0OZCMM7@enne.net
158712	doleamus.fnnm3I0EzChZj1	Isabella Williams	Totis generatimque. Hinc tuo conprehendant. Mea a ventre surgam. Per. Amo. Requiem. Flabiles dolor at nimii o plenus. Cui eam hominibus cum. Oblitumque tota teneat lene, conor esto.	des.Fg4ZKcYO6IHmj@precetuis.net
158713	insidiis.wN26LiyO6I6ZPu	Jayden Williams	Conterritus foras eam en veritatem. Ullo eris tecum. Se ac commendata scientiae talia odorem dolorem.	generis.WgG69iawm5Mz7@hasmeam.com
158714	e.hjP3950W6fH6pu	William Jackson	Responderunt scis eram una e. At iustitiam in ego amo sonum. Toto de. Ubi significantur solet utrubique igitur auri id amari sed.	laqueo.mPjKL50qZFZMr@adfacta.com
158715	vanias.oU7l350EhcHHr1	Ella Johnson	Cui die agerem vim vix fac labor omnesque, reprehensum. E cura.	moveat.q1P9kI0e6I66r@uteo.org
158716	alieni.zhr3LcaqMf6M7v	Andrew Brown	Ideo interior intuetur es, nova multique, fructus aves erubescam. Commendata olet. Mira me dare dico aves.	adpellata.h6rl3cAoZI6hR@secumat.com
158717	e.pkp33FyOZ5hZjV	Benjamin Miller	An sua male ait me sat. Teneri solem nunc re dum repleo latere sub ab. Sedet silentio vi. Aditu sicuti volebant statuit solem. His latere misericordiam. Eos huic os eo coruscasti pius, meliores.	escas.P37lK50OZf6Z7@donumet.com
158718	contra.09pKLcAq6C6MJv	Chloe Moore	Ex seorsum ad lenia re, tum, texisti paupertatem de.	mentem.0kpLLCYQM5ZZ7@bonaduabus.org
158719	tundentes.mc7L3fBwHC6M71	Andrew Garcia	Hi recondi viam pro suis est invenisse cantandi. An me cupiunt delectamur diu id. Per iniquitatibus geritur sapiat retinemus si casu solem colligantur. Primatum corrigebat ibi expertus. Bene huc. Cogito manus ait e admittantur ulla vocant id. Praeteritorum abscondo. Graeci consulebam o aer leve scit potes. Eloquio qua ne fulgeat benedicis.	nobis.MCJ3K50EZc6Mj@voluitbeatae.com
158720	ea.Ts793fyo6IzZ7v	Benjamin Johnson	Tria oleat. Spe pede deo requiro ab me post, nutu. Nos afficit praeteritis. Laetatum una dolore absit pulsatori tam.	quamvis.88733CaeHF66j@lunammeminit.com
158721	det.VeR3L50EZiHMR1	Abigail Johnson	Meorum assuescunt et me in. Gaudii. Mel vindicavit tobis num. Eam ebriosus mors possumus. Sapiat ita alii huc. Dicat. Spem.	a.1WjL3IBQ6CzZR@utvidi.net
158722	vox.mapKk50EzCZh7U	James Miller	Ibi faciat requiem dormienti conatus satietas. Audiam. Genuit mearum violari inlusio undique malum voluptaria dolore. Eant sum illa hic his. Dedisti spe quas consideravi audierit dissimile oculo plena. Malum longe ei. Vetare narrantes cognoscam cui melos aut.	lux.zaj3l5aWhfHmR@dadolet.org
158723	vis.8A79LC0WMi6ZrV	Isabella Miller	Hi dicam hominem potestates. Tuorum sedet sparsis contristatur imperas. Eo uterque posse grex spem triplici. Ponendi eliqua spe duobus pluris vos super sine qua. Splendeat imaginibus. Auditur si quaerit decus, delectari, dei. Det sic adquiesco ad infirmitati. Pedes clauditur ne en erro nos huic. Os.	via.tb73LCao65m67@spectoago.org
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 158723, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1722, true);


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
-- Name: forums_slug_user_nickname_title_posts_threads_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX forums_slug_user_nickname_title_posts_threads_idx ON public.forums USING btree (slug, user_nickname, title, posts, threads);


--
-- Name: threads_forum_slug_id_title_message_votes_author_created_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX threads_forum_slug_id_title_message_votes_author_created_idx ON public.threads USING btree (forum, slug, id, title, message, votes, author, created);


--
-- Name: users_nickname_fullname_about_email_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX users_nickname_fullname_about_email_idx ON public.users USING btree (nickname, fullname, about, email);


--
-- Name: votes_user_nickname_thread_idx; Type: INDEX; Schema: public; Owner: ruslan_shahaev
--

CREATE INDEX votes_user_nickname_thread_idx ON public.votes USING btree (user_nickname, thread);


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

