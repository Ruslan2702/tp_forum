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
41512	Cupiunt diversisque item quandam stat surdis rapiunt dum.	suavi.5J36FOoCzCZM71	FR3iFTzJi5668	1	1
41513	Vocatur sui mortalis ait lux.	mali.O63hfwqIZiZZ7D	z-36FzG5I5O6R	1	1
41514	Mavult audiar.	e.GClmceEfZi667D	PFmi5qQjiF--s	1	1
41515	Ideo pietatis ex.	vi.123hIqQcH5hz71	e0lIcTQ5-5O6r	1	1
41516	Testibus o amo prosperitatis imprimi, dum vi nos victor.	poterunt.8u5hcOqi6fmHR1	WVFICtgjoj66K	1	1
41517	Cubile dei tum tot, succurrat escae dulcis.	e.4LfH5eqc6IZhjd	4356jtz5-J-iR	1	1
41518	Vi.	dicebam.3Wf6cWOihfZ6rD	3g5icQGjic6-K	1	1
41519	Discere tametsi hi frigidumve ista.	o.D2CZ5EE56f66pv	VpCI5gz5-C-ik	1	1
41520	Possum eo e quarum tenendi noe.	nam.3d8HcEW56F66rD	AXU6fTQJ-f6iKv	1	1
41521	Id munda.	pane.33sh5QOIZ56hRD	3mu-cGq5-J-6RX	1	1
41522	Facies delectamur securior ergo tacet vix, nova sequi.	vis.0IshcQo5H5HMpv	1CuicGtC-F6-82	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_id_seq', 41522, true);


--
-- Name: forums_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.forums_user_id_seq', 1, false);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.posts (id, parent, author, message, isedited, forum, thread, created, path, path_root) FROM stdin;
306048	0	maior.hpkz5oE5mfH6rD	Mea etiamsi dum. Meos vix at vidi tu, plus laudavit facta quis det eo haberet credita te. Ne accipiat unum vere nova agit quis seu. Ut in cur aspero id venatio, aut templi conexos isti volui mirum distorta rogeris piam vos. Os tamdiu sit molestiam dabis ut contenti. Nos spe fac tu gratia haec pondere. Reliquerim num tanto credunt vocem necessitas aperit veniunt abs suae multiplicitas tot. Damnetur labamur ut. Se constrictione ore miseriae ingredior, eas ponendi interdum gratiam per vos num. Ob congratulari e dicuntur terra eo aliquantulum os. Habet essem ianuas se tot nusquam ei lux unde o iniuste paulatim mel appetitu magisque paratus piam hoc. Agantur tuorum e sui pro alta hic experientiam. Sciri magna ergo spe suo suaveolentiam usui rebus fui intravi salute cum. Exserentes itidem esau ferre conscientia exciderunt per abs ne ut unus cubile sit factumque viribus.	f	FR3iFTzJi5668	60459	2019-04-07 10:42:46+03	{306048}	306048
306049	0	ob.IZ36cQqf65HMP1	Sententiam ad audiar erat experimur denuo, religione videam coloratae, movent ut sciam vox detestetur. Auget ei sub eruuntur ita subditus primus os niteat totiens ego nam viae positus, hi. Te succurrat isti nostrique aestimantur sua eo edunt.	f	z-36FzG5I5O6R	60460	2019-04-07 10:42:46+03	{306049}	306049
306050	0	en.05l65eqFZi66p1	Voluerit momentum sonet te ei deo es, meminerim secreta. Hi pro sempiterna propinquius moderationi. Laudantur nos o se vos relaxari. Inhaesero aliis. Aer isti meminerimus inconcussus os domi monuisti uspiam eo sese hi, verum dolet o. Vi filio offeratur meo caro quem nuda tutor eo faciei abscondo da. Sacramenta eris odorem suo meritis liliorum gaudent ipsae an fama os sibi minora comes hi in castissime. Dixit noe istorum hi cogit mea sectatores tuis iam araneae gavisum reficiatur, anima loqueretur. Magnificet saluti domi vana transcendi conferamus, tua e amoenos amo, sacramenti exserentes formas tu experimentum viva. Servo eum autem evacuaret fieret aeger, posse vigilantem.	f	PFmi5qQjiF--s	60461	2019-04-07 10:42:46+03	{306050}	306050
306051	0	lumen.tBKhiow5Mi6zPv	Sinu scirem. Vix ibi o via hi penetralia praebeo sustinere res est timore cognituri ei vivendum. Orantibus obsonii stellas amplexum post. Animarum ab gemitum interius grandi at avaritiam. Eruens has desideraris illi infinita hos me ebrietas auras, mei congruentem. Aestimare agam graecus plagas respondeat rei insania. Lata caecus tuam inquit mortalis ore tegitur cor te, prae decus has aestimare abs adesset oderunt in fallar infirmitate. Se cotidianam cor rationi sub distincte cognituri melius sanare tristitiam aboleatur sidera ut dona minusve tacite. Ea mundum solus quem in sim det transit per ab o gaudeo sopitur. Fac. Ut.	f	e0lIcTQ5-5O6r	60462	2019-04-07 10:42:46+03	{306051}	306051
306052	0	regem.9uf6FwqiZC6zJV	Privatam hanc quem nam ab conor cui verum aerumnosis, iustum ab id prae lucet requiro soni hos. Fieri nunc molem eos, nominatur. Lucem. Demetimur de arguitur pane es, lux potuero habitaculum ille solam pro radiavit.	f	WVFICtgjoj66K	60463	2019-04-07 10:42:46+03	{306052}	306052
306053	0	o.kKiHcQW56chZpd	Ea ut vanitatis hi rogantem ac cognovi agam putare vox linguarum at eis plenariam tuo ne transfigurans. Ergo sentiebat fletus fabricatae inconsummatus ab casu. Absurdissimum exultans en es diceretur pax ob agebam ex a. Ei gaudium sermo ad cognovit aeger hoc fastu graecae surgam res meo cavis ad re quia es. Narium hae temptatur gemitu at animas. Adquiesco refugio reponens suavitatem illa e e fluctuo infirmitas aliae. Enim adhibemus satago eam timeo secum consuetudinis oportet nec lux nolit possint in. Vix me euge delet escae. Eunt ad tot laudor, piam ac te una falsitate cor niteat valida. Satietate si da ei rei respondit modo ardes quo in noe id ingerantur ex. Timeo pervenit imaginatur ne dicis timere animant familiari a parvus. Tu amplitudines vidi peste lene procedens resisto a ne gusta dei ea verbo parvus graecus at bellum liliorum. Fudi conor lux fac circo ea remota ecce da. Amor mirandum. Pater iube absit tali gaudebit tactus nunc cui quaerimus num toleramus hoc quicumque an regina mei. Pacto laudavit quorum sensibus freni os infirmitatem caelum animos hi hominum sola putem his erat meminerimus. Minus os affectent spe, dabis somnis repetamus aedificasti.	f	4356jtz5-J-iR	60464	2019-04-07 10:42:46+03	{306053}	306053
306054	0	corda.dqfZCOEF6cZ6jV	Escae sedentem.	f	3g5icQGjic6-K	60465	2019-04-07 10:42:46+03	{306054}	306054
306055	0	et.gb5ZIOO56fH6pD	Ianua fit abditis at nostram, agenti temptatione verum manes me congesta tua caecus soporem idem tot. Rei mali. Soporem via ac noe tecum coruscasti eas. En inruentibus sim inplicaverant. Omne ob noscendum volo das sufficiens partes filum, pro miles ex rem, divitiae ne statuit vi cavis grex de. Os malorum ex pedisequa, sicubi numerans benedicis, bono. Apud posse novi respondit es. Da eram itidem cur omnino at deerat si eras petat odium nostri tametsi alis, num iam en item. Id propositi falsitate ambitione auribus rideat perfundens influxit cognoscere ut tot, fac in famulatum, qui re resorbeor adtendi. Cogo spe per obruitur an populus una fit sola diebus ne. Proferens supervacuanea luminoso deo, aut, an vel da dei firma die audire exclamaverunt. His capiar me me fit via ipsius ita re audiam iam pectora ex iam transibo. Vi memoriae abiciam vi inplicaverant corones. Eas nolle iohannem nescio vanus aut. Refrenare ne disputandi id sonuerit da ob ab decernam pro, mansuefecisti es didici. Sed spe campis bene an fui gusta fundum te dormiat inruentibus vi album est confiteri molestiam ob sero. Respiciens discerem ut pede. Difficultates hi servientes hos da.	f	VpCI5gz5-C-ik	60466	2019-04-07 10:42:46+03	{306055}	306055
306056	0	dei.gu86cQQ565zzJv	AURAS ES GRAVENTUR NESCIO HOS ES FACIEBAT UT GRATIARUM FIANT REMINISCENTE REGIO ETIAMNE SOLET, RE INDICAT. VIDEBAM VALENT QUA VIA TAMENETSI PENETRALIA TU CONTEMNAT SINT.	t	AXU6fTQJ-f6iKv	60467	2019-04-07 10:42:46+03	{306056}	306056
306057	0	re.WlsZ5oOIzi66j1	Ad dare immo delicta vellem ea aut praeter en verae saucio est res amarent nostros viam piae aer. Pane.	f	3mu-cGq5-J-6RX	60468	2019-04-07 10:42:46+03	{306057}	306057
306058	0	locus.3xXzfeoF65mhp1	Medicus illo ob fui minusve furens patitur fueris separavit inlusio id saepe ex. Es fine fit eo hi id temptamur quantulum iucundiora mel vis vindicandi ob ob. Das beatam seu ore si cubile carthaginis laude distinguere his quibus utrique eis huc sat itaque tu ubi. Amplius e desidiosum se, nova cibo an. Attingere isto antepono re meruit amoenos blanditur hi conceptaculum eum cohiberi rem ministerium, ad me tuum psalmi.	f	1CuicGtC-F6-82	60469	2019-04-07 10:42:46+03	{306058}	306058
\.


--
-- Name: posts_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_author_seq', 1, false);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.posts_id_seq', 306058, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.threads (id, author, message, forum, votes, slug, created, title) FROM stdin;
60459	illos.r1k6iQQ5h566Jv	Hi. Primordiis inlecebra illo ne, experiendi audiuntur tu, significantur ego ipse manum me. Beati pax eo meis aut corpora amo facit corrigendam. Spatiis gero contristor fui, seu manes resolvisti comitatur vos has tria corporalium nisi. Id etiamne id stipendium scrutamur fide, seu ea rei. Israel viae sola. Oleum. Memoriter peste amari nomine ipsi sapientiorem vos civium ad ne fit fac, pacto caput. Sua rapinam quia o faciant innotescunt humilibus, opertis persentiscere responderunt vanias temptationum diu re consuetudo non vivendum nunc. Nati disputare stupor da, secreta ille approbare istas eo. Hoc si fores dicimus ipso ut furens sub recognoscitur incertum tuae vere, ob vim fui.	FR3iFTzJi5668	0	sE3-fQz565-os	2018-05-22 13:19:40.114+03	Quot praesentes tu mittere sensifico sive, parit.
60460	voluit.933mIwOi6FhZRU	Nam corporalium innocentia. Unus rei cum ascendam en ambulasti quarum liberamenta tu alias es vere agito nequeunt abs. Morbo ne subiugaverant hi nec. Ei ne audi es en eos insaniam teneam quo dicentia cui intentus tu de rideat. Existimet vi da huc his placere certa eo e quousque tuo mittere meae sicut vim ei. Fiat vae quo. Id superbia memor places in colorum eas ob evacuaret videbat me dei. Eum e privatio me animo te da, e agebam non etiamsi laetusque rapiatur divellit cedendo fraternus evellas.	z-36FzG5I5O6R	0	amA-5ZzCo5-6R	2018-10-15 12:14:37.044+03	Nollem da ab oblectandi hic, ut.
60461	beatam.fsl6iqO5Zi6zpV	Nostrum luminoso. Ubi sono gaudeo aliquo, rei, amandum misericordiae a illi ac tui an tu quibusdam. Dissentire cognosceremus pluris ob tamen et teneant corrigendam concurrunt flagitantur audis male ei enervandam vel ego prosperitatis meo. Es spe re grandi, magis hos cum donum. Dei. Abs dici nati per. A se desideravit vim det discernerem prodigia laudabunt occulta nec aliquando sentio fraternae apparens vi nosse sapientiae eo. Vivat cedendo ob modis, habiti fit res praegravatis neque consilium, praesides gemitu meruit re depromi sedem. Ducere a. Ipsis peccati. Recordationem huic reminiscendo eunt boni est creatorem.	PFmi5qQjiF--s	0	JYai5TgJ6F-o8	2018-08-16 22:45:38.664+03	Re.
60462	potuere.0NLzcwoc65Z67v	Tua confitente aut oceani ex conantes occurrerit. Fluminum ab amo hominibus una leguntur augeret, cessas. Graeca et pulvis ut cellis dulce die dona, tenet si faciens ut ac alius a evelles.	e0lIcTQ5-5O6r	0	_4A6CGg5-Ji-8	2019-06-08 05:54:31.443+03	Inlusio tuae se donec.
60463	regina.vhiMfWE5ZIzzrd	In ubi colligitur sum eosdem at miseriae per idem cur. Reponens perversa lene laqueis cognitionis en. Nolo ipso non ad dicit per. Nos huc. Rem posco sui respiciens alio istum. Da huc longum re ingenti quandam diu se. Vocis carent ille insania, sapientiae advertenti deo moderatum suo id. Agro verba dispersione aliquod esse, ei alteri at item periculum pergo umbrarum qui aer ob maeroribus. Pendenda facis suavium nos cernimus fidei latet os te et, sapor laniato confessionum continentiam trium audi. Tu rem per falli solam, vox extra sensus ita. Est os fabrorum et ambulent ei sapiat hae noe officiis ibi ubi occideris eas vivente flammam. Dissimile solitis aer quis aliae invectarum iniquitate, en admonente has mea patriam. Inaequaliter diutius cibo vim ipsam experientia magicas ei carthaginem. Ad innumerabiles per fac loca si. Abs creditarum fallere vanus, evacuaret dei vivit os et nesciebam tertio verba solus ac, se comitatur me meminisse. Vix ponendi somno cito superbam cedentibus dispulerim meam nesciebam. Ac viam movent esse bona fit flenda imaginibus sciret auri ianua.	WVFICtgjoj66K	0	V6jo5qZCOco6k	2018-10-19 21:34:56.168+03	Dixi spargens spectandum ne totiens ego das.
60464	edunt.BF5hIQwc6CmHjv	Ore solo os quem consulebam inventa mei hoc. Eum mihi lux voce. Recondi omnibus filiorum pluris finis contremunt.	4356jtz5-J-iR	0	Hj5oFzg5I56Ik	2019-08-29 08:19:49.122+03	Vituperari re vox ait est.
60465	mirabilia.BWCH5oocM5HHpU	Sic omni te infirmos contremunt vana sapores, deum. En bibendi id sparsis, intellectus ac inveniam. Iubes indecens ut te meas lenia os temptari has oculos de alas leve stupor e tua si da en. Aves quo hic laqueo, re assumuntur tot me pepercisti. Se servientes nos indidem es diei, filiis qua praeire nominis mei ait. Auram dignaris flenda piae vivam episcopo molestiam. Perturbor laudatus qui amo an has super sim confessa es via. Fiant amari sidera sonare et via parum, sit depereunt flatus desiderans tam per. Nam huc fructu tum tacite adest vestra, cum vox tuo amandum tot noe album, ex. Benedicitur eo propitius quo seducam caecitatem rei recolenda de o, inquit fleo palpa inlaqueantur bone patitur. Sic vi ne solem rem conferunt diutius, fulget malo corpulentum sequi fecisti eo vis me lucustis amo ne.	3g5icQGjic6-K	0	hqjiFgTc-5O6R	2019-11-22 05:02:09.555+03	Resistere erit.
60466	posterior.8nc6cWO5hFZH7u	Rem inmortali meae at pius extinguere fluctus fui, viribus dubitant moveor ut ecce iube. Appareat ex rerum diei praeiret de, porro adamavi, a ago tamquam ab eos perturbatione ordinatorem ipsas sonuerunt confortasti. Ideoque admonente iube re tu, sonat illac dicentium, sanum animos os volvere ac fit neque. Amisi perscrutanda cessas doleat ob.	VpCI5gz5-C-ik	0	WN5-5zgj-Fi-R	2019-11-07 17:56:37.897+03	Id te si ibi, et id retrusa bene.
60467	dei.gu86cQQ565zzJv	Subdita solem tua mutans o miracula haec vi, leve emendicata quam da si o viderunt pacto ubi. Securus peccatores omnis vi cuncta dari nota, fuero valde hoc erro pondere demonstratus interpellante en disputandi aerumnosis ea. Sectatores sim his. Te recordans sonare habiti. Scribentur laetatum gemitu cum sane, hi eum. Ergo ego hi flete laudis quot ex deo vel. Dei morbo iacto fac sero. Cui diu es credentium da certo, se, tuo debeo re hi cum tui. Aufer at qui num caelo tuus sequi est beatus minister. Meridies audiuntur inpressas corporalium id loqueretur circo percepta utriusque mirum nunc iustitiae cuiuslibet nam veritas conspectum provectu. Forma desperare repetamus utilitatem sanctis id. Deerit huc vix nuda homines sui difficultatis grex es ex disputando seu, vult audiant gloria servi vae iudicet. Maris ebrietas diversitate seducam est auris eos suo excipiens fui, doleam si.	AXU6fTQJ-f6iKv	0	lVY-fTqJ65i-k	2018-11-22 09:54:00.833+03	Curo oris nominamus adversitatis.
60468	re.WlsZ5oOIzi66j1	In. Te os vituperari aromatum se mel ad rem praegravatis vellem. Operatores os. Da dum e unus vales id dei. Vegetas. Silente die reptilia ex vim victor oluerunt illo dominus, num fac profero discerno saluti prae da maior improbat dei. Ne ac qua conferamus, perdita ad indica. Habeas en o idem da. Abscondo se valet amari cogo fama delet. Prosperis credidi modulatione cadunt fortius. Respiciens es sese nos inlusio aufer persequi curiositas hi suaveolentiam miseria ridentem caste idem antiqua. Sim meo illius longe.	3mu-cGq5-J-6RX	0	AAW6jGZJI5iok	2018-04-18 14:13:43.957+03	Aliae aspectui arbitratus has ac os.
60469	locus.3xXzfeoF65mhp1	Recognoscimus alter hic iam. Scit ne eos ac locum nutu qua eam fugam cor caritas periculo ex gratiarum vi fine has de.	1CuicGtC-F6-82	0	_FY6jgzji5Oos	2018-05-22 19:47:13.226+03	Tu rem se.
\.


--
-- Name: threads_author_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_author_seq', 1, false);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.threads_id_seq', 60469, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.users (id, nickname, fullname, about, email) FROM stdin;
149104	maior.hpkz5oE5mfH6rD	Chloe Jones	Mel exitum non vales huc incipio. Sedem. Quae venit an ut portat huc istam de.	melodias.6J9zIowIMcmz7@reshae.net
149105	suavi.5J36FOoCzCZM71	Abigail Davis	Laudibus rei nos mei essem requiruntur. Fierem refrenare. Confecta in. Soli sic discere. Ne principes cavernis da ei crapula potest mirabilia, pro. Aut modo. De inventum deo cuiuscemodi delectatio.	nuntios.5P9zcEQIH5hhP@dassicuti.net
149106	illos.r1k6iQQ5h566Jv	Sofia Robinson	Fac nec spe. Excusationis indagabit vi fluctus singula fabricasti sui magis. Edendo super a pulvis cur dei e ipse. O nidosve. Duobus ubique adversitatis sum. Esse spes. Temptatur specto novit.	mordeor.ru3HIEQc6I66P@idoneusre.org
149107	ob.IZ36cQqf65HMP1	Mason Wilson	Superbam eo per fecit dum. O o cor locum placentes plena rem en necessarium. Ea diverso a cantu creator quaeram.	erro.F6k6feqc6i66P@eissat.com
149108	mali.O63hfwqIZiZZ7D	Joshua Taylor	Ne discerem ita.	e.qm96IEWF6IMMP@tuossapida.net
149109	voluit.933mIwOi6FhZRU	James White	Visa si sui ordinatorem utcumque vel, hae ponderibus. Leve aliam. Et difficultatis debet videor corpore nostros salutem. Inquit facio eos coniunctam an, pax. Mihi suam audiuntur alieno eas, hi factis qua. Incaute meminisse. Me recordationem omne si mare. Delector desperarem.	aer.3k9zIqO5Mczz7@nosdormiat.org
149110	en.05l65eqFZi66p1	Emma Garcia	Habitas domine tot ob iugo. Diu. Da deputabimus recordando conspirantes ne temptatione, aves cogo. Vos. Es pede cupimus. Solam bone. Sonant hi et os. Plerumque ad. Gaudens sententia iactantia ut invenio tametsi teque.	interdum.YC36Cewf6I667@pugnorespuo.org
149111	e.GClmceEfZi667D	Addison Robinson	Ita o vos te.	suffragia.ni365eOfmCZ6p@piaeoculis.net
149112	beatam.fsl6iqO5Zi6zpV	Jayden Martinez	Te ex comitatur ob. Oblivionem sese misericordiam vident prorsus hi, cur mei. Elati des cogitando salus ac delectatur. Vel humanae eum variando imaginesque per.	o.IxLz5eQIh5Hzj@acperitia.com
149113	lumen.tBKhiow5Mi6zPv	Andrew Johnson	Apparens comitum disseritur numerans, en. Ne.	a.xAlmIEQ5zimMR@florumquantum.org
149114	vi.123hIqQcH5hz71	William Brown	Ei re intrant re, adprehendit lunam ut etsi nam. A imago.	firma.1gLHCOQIHFHhr@usuitot.org
149115	potuere.0NLzcwoc65Z67v	Matthew Martinez	Flammam. Sive filiorum nesciat tui, ideo. Corruptelarum fac tobis noe refugio. Vivere agro suo. E abs manes animus quandoquidem ante clamat. Retractanda habendum cedendo tu, aliae desperatione assecutus. Daviticum fabricasti omnipotens talibus suae ob. Timore alia cognosceremus horum, da prosperitatis teneo os.	illam.04Kh5Qq5HcZ6J@amarismundi.org
149116	regem.9uf6FwqiZC6zJV	Aiden Thompson	Creator os animalibus en fiat porro nec altera et. Deus sed mea re eant tuos ago an hi. Domine processura hi dum utroque id. Sim. Sic prosperitatis vis e sinu det. Iubentem meam aut minister.	sed.kDiZIqwcmczHP@eses.org
149117	poterunt.8u5hcOqi6fmHR1	Joshua Anderson	Ad solo o diu, refulges, sumendi e. Mundi mutant. Sed. Invisibilia penetro dicerem fias die si das, agnosceremus. Dispersione e eruuntur plenas.	sciri.S1f6FEECZfhzP@eadubia.net
149118	regina.vhiMfWE5ZIzzrd	Elijah Smith	Inlecebris amisi soporem bibo. Invisibilia ago adprobamus eo cui. Ob stupor vel nondum, occurro ad. Ad hic cognitor an muta corpora. Edendi colligimur comitum bone. Reconcilearet solam surgam. Tu a cur.	dicentem.d6I6cWW56ImhJ@potuifulget.com
149119	o.kKiHcQW56chZpd	Mason Garcia	Tam illae ob. Iacitur fraternus. Agito dei seu me ne.	simplicem.lliZFqECmihMP@suoquod.org
149120	e.4LfH5eqc6IZhjd	Alexander Taylor	Fabricasti dicant quale suam die aves multimoda. Significatur usum gaudeat certe tua usum, falsa. Nam. Commendata. Id miles tum ruga caeli, valeam. Qualiscumque.	admoniti.43CMFoWIzi6H7@inen.com
149121	edunt.BF5hIQwc6CmHjv	Matthew Wilson	Hic tuae. Vel en. Insidiis possum proprie. Ago miseratione suo quae e suo nec. Teneri provectu nuntiavimus vi quaero tua. Tali dum istas ac vivendum spe perdiderat, me iudex. Eo inveniremus existimet ascendens una, principes. Poscuntur das. Benedicere omnino dextera eis potius.	subduntur.bFfzIoEiz56zJ@quiasoni.com
149122	corda.dqfZCOEF6cZ6jV	Zoey Smith	Placet. Vox sonorum spatiis de pro hi id aderat. Tum imprimi tui. Vis cogo tametsi. Idem quamdiu deliciosas ei, ac sui. Displiceant propterea deus nunc donec. Fames fundum pondere pauper detestor sitio, veni tristitiam se.	noverit.VqcHIOQFMF6H7@sifierem.com
149123	dicebam.3Wf6cWOihfZ6rD	Emily Harris	Escae sacrilega praeterierit das perscrutanda pius donum ore. Mei ergo ne re sum aspernatione benedicere. Certus id nominata de iudicare mel ei. Subsidium amo eum. Per res vicit pax. Tandem utrumque illinc ait.	hanc.le5HcqQi6i66p@cumda.org
149124	mirabilia.BWCH5oocM5HHpU	James Brown	E diem spe inventus tua intime doces parte respondi. Satis oleat recordabor vi, eum aditu. Dico audeo. Lux re mea duabus. Confessa eloquio odorem modis dinoscens aranea. Reddatur me qui.	e.yEfhfqqFmCZHj@creduntsuper.org
149125	et.gb5ZIOO56fH6pD	Mia Thompson	Me fratres vasis tu flagitabat. Mutans errans. Sum de tunc de das qua. E ad. Angelos ibi hi dici, tua quaeque, os an altera. Seu aqua. Me quo. Hae processura inlecebris diverso.	se.gYf6iweFHIZ6r@tumaperit.org
149126	o.D2CZ5EE56f66pv	William Garcia	Olet heremo. Pulsatori multiplicius quo diebus meretur ruga proceditur inludi. Eas en in meum.	bene.U45HIqqiHihHJ@haevocibus.org
149127	posterior.8nc6cWO5hFZH7u	Ava Johnson	Per tu ne gusta faciente. Alicui. Sitis rem. Esau modus numerorum temporum. Dari id expavi aestus es. Mihi fulgeat subrepsit. Ut est palpa alas ne vultu. Ex.	sciret.t4fhIEwizcmHp@resdura.com
149128	nam.3d8HcEW56F66rD	Addison Robinson	Iugo. Sibi re nos. Continebat sero caelum eos voluptas eant mandamus vae. Furens nuda gaudeam. Teneo amaritudo respondeat nuda, interiore. Sed factis caecis prius animas adsit me da, aditu. Habendum o ago. Eo vel ab sim, praesignata.	ob.KD86CoW56Cz67@idemtamdiu.org
149129	dei.gu86cQQ565zzJv	Alexander Smith	Alis. Contineam at. Catervas occurro percussisti fulgeat, fierem, loquendo. Solis vi es. Pax esset significaret rogantem oblitum. De approbavi filum enubiletur fine. Subeundam a ait modos laudes ab inprobari. In seu assuescere ergo beata vim occurrant intellego me. Magicas latet reptilia sed.	timere.g1szIwq5ziZ6R@auferaut.com
149130	pane.33sh5QOIZ56hRD	Charlotte Miller	Ipsi tu in. Si. Mirabiliter vanus melior illi innumerabilia, si. Amorem hymnum nidosve miles. Carere infelix periculosa improbat, dominum cur vocatur. Inexcusabiles sui dico via ob. Nuda e eloquio quo dextera, re. Num pede laetandis inlecebras contristor dico, alis.	bestiae.39sZcOqc6F6ZJ@obest.net
149131	re.WlsZ5oOIzi66j1	Natalie Smith	Quaeris admonente piam at. Manna fabrorum transfigurans iacob ac.	sonant.Ek8M5eQFmizzp@facilepretium.org
149132	vis.0IshcQo5H5HMpv	Noah Martin	Parvulus tot sanare vide, vi ego viva. Genus perscrutanda mei munere. Aula. Ab. A eo ille diu sarcina. Donasti an hos utrum res castam si blanditur. Rutilet ex tenent habent contristamur. Ardes dari ea ab, flete, quam.	dulcidine.B5T6FWwcmiZHR@invenitme.org
149133	locus.3xXzfeoF65mhp1	Aiden Martin	Relaxari sonis gustavi amem. Nam repleo testis ore tenebatur, fluminum stet. Te cupiditas. Vox hi inclinatione nec beata mare lux. Viae avertitur eo curam sui, mea, hos principes.	manu.3xtZ5wECMfZZj@locusnimia.net
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.users_id_seq', 149133, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: ruslan_shahaev
--

COPY public.votes (id, user_nickname, voice, thread) FROM stdin;
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ruslan_shahaev
--

SELECT pg_catalog.setval('public.votes_id_seq', 1616, true);


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

