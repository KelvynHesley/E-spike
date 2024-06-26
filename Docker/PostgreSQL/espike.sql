PGDMP                      |            espike    16.3 (Debian 16.3-1.pgdg120+1)    16.3 (Debian 16.3-1.pgdg120+1) 6    V           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            W           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            X           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            Y           1262    16384    espike    DATABASE     q   CREATE DATABASE espike WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE espike;
                postgres    false            �            1255    16443    check_severity_and_notify()    FUNCTION     �  CREATE FUNCTION public.check_severity_and_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.severity_level = 'High' THEN
        -- Simula o envio de notificação inserindo um registro em uma tabela de log
        INSERT INTO alert_notifications_log (alert_id, notification_time, message)
        VALUES (NEW.id, NOW(), 'High severity alert detected: ' || NEW.alert_message);
    END IF;
    RETURN NEW;
END;
$$;
 2   DROP FUNCTION public.check_severity_and_notify();
       public          postgres    false            �            1255    16440    check_user_reputation()    FUNCTION       CREATE FUNCTION public.check_user_reputation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_average_rating DECIMAL;
BEGIN
    SELECT AVG(rating) INTO user_average_rating
    FROM tb_ratings
    WHERE id_rating_user = NEW.id_reporting_user;

    IF user_average_rating < 3.0 THEN -- Defina um limiar de reputação
        NEW.status := 'Em Análise'; -- Ou outra ação apropriada
        RAISE NOTICE 'Ocorrência reportada por usuário com baixa reputação. Em análise.';
    END IF;

    RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.check_user_reputation();
       public          postgres    false            �            1255    16438    log_occurrence_status_change()    FUNCTION     A  CREATE FUNCTION public.log_occurrence_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO tb_occurrence_logs (id_occurrence, old_status, new_status)
        VALUES (OLD.id_occurrence, OLD.status, NEW.status);
    END IF;

    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.log_occurrence_status_change();
       public          postgres    false            �            1255    16441    set_alert_time()    FUNCTION     �   CREATE FUNCTION public.set_alert_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.alert_time := NOW();
    RETURN NEW;
END;
$$;
 '   DROP FUNCTION public.set_alert_time();
       public          postgres    false            �            1259    16445    alert_notifications_log    TABLE     �   CREATE TABLE public.alert_notifications_log (
    log_id integer NOT NULL,
    alert_id integer,
    notification_time timestamp without time zone,
    message text
);
 +   DROP TABLE public.alert_notifications_log;
       public         heap    postgres    false            �            1259    16444 "   alert_notifications_log_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.alert_notifications_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.alert_notifications_log_log_id_seq;
       public          postgres    false    226            Z           0    0 "   alert_notifications_log_log_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.alert_notifications_log_log_id_seq OWNED BY public.alert_notifications_log.log_id;
          public          postgres    false    225            �            1259    16408 	   tb_alerts    TABLE     8  CREATE TABLE public.tb_alerts (
    id integer NOT NULL,
    alert_radius integer NOT NULL,
    severity_level character varying(20) NOT NULL,
    alert_message text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    alert_time timestamp without time zone NOT NULL
);
    DROP TABLE public.tb_alerts;
       public         heap    postgres    false            �            1259    16407    tb_alerts_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.tb_alerts_id_seq;
       public          postgres    false    220            [           0    0    tb_alerts_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.tb_alerts_id_seq OWNED BY public.tb_alerts.id;
          public          postgres    false    219            �            1259    16417 
   tb_markers    TABLE     �   CREATE TABLE public.tb_markers (
    id integer NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    description text
);
    DROP TABLE public.tb_markers;
       public         heap    postgres    false            �            1259    16416    tb_markers_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_markers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.tb_markers_id_seq;
       public          postgres    false    222            \           0    0    tb_markers_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.tb_markers_id_seq OWNED BY public.tb_markers.id;
          public          postgres    false    221            �            1259    16426    tb_occurrence_logs    TABLE       CREATE TABLE public.tb_occurrence_logs (
    id_log integer NOT NULL,
    id_occurrence integer NOT NULL,
    old_status character varying(20),
    new_status character varying(20),
    change_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 &   DROP TABLE public.tb_occurrence_logs;
       public         heap    postgres    false            �            1259    16425    tb_occurrence_logs_id_log_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_occurrence_logs_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.tb_occurrence_logs_id_log_seq;
       public          postgres    false    224            ]           0    0    tb_occurrence_logs_id_log_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.tb_occurrence_logs_id_log_seq OWNED BY public.tb_occurrence_logs.id_log;
          public          postgres    false    223            �            1259    16398    tb_occurrences    TABLE     �  CREATE TABLE public.tb_occurrences (
    id integer NOT NULL,
    description text NOT NULL,
    occurrence_type character varying(50) NOT NULL,
    date_time timestamp without time zone NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    status character varying(20) NOT NULL,
    CONSTRAINT tb_occurrences_status_check CHECK (((status)::text = ANY ((ARRAY['ativo'::character varying, 'inativo'::character varying])::text[])))
);
 "   DROP TABLE public.tb_occurrences;
       public         heap    postgres    false            �            1259    16397    tb_occurrences_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_occurrences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.tb_occurrences_id_seq;
       public          postgres    false    218            ^           0    0    tb_occurrences_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.tb_occurrences_id_seq OWNED BY public.tb_occurrences.id;
          public          postgres    false    217            �            1259    16386    tb_users    TABLE     �  CREATE TABLE public.tb_users (
    id integer NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    user_type character varying(20) NOT NULL,
    name character varying(100),
    cpf character varying(10),
    phone character varying(15),
    CONSTRAINT tb_users_user_type_check CHECK (((user_type)::text = ANY ((ARRAY['user'::character varying, 'mod'::character varying])::text[])))
);
    DROP TABLE public.tb_users;
       public         heap    postgres    false            �            1259    16385    tb_users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tb_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.tb_users_id_seq;
       public          postgres    false    216            _           0    0    tb_users_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.tb_users_id_seq OWNED BY public.tb_users.id;
          public          postgres    false    215            �           2604    16448    alert_notifications_log log_id    DEFAULT     �   ALTER TABLE ONLY public.alert_notifications_log ALTER COLUMN log_id SET DEFAULT nextval('public.alert_notifications_log_log_id_seq'::regclass);
 M   ALTER TABLE public.alert_notifications_log ALTER COLUMN log_id DROP DEFAULT;
       public          postgres    false    225    226    226            �           2604    16411    tb_alerts id    DEFAULT     l   ALTER TABLE ONLY public.tb_alerts ALTER COLUMN id SET DEFAULT nextval('public.tb_alerts_id_seq'::regclass);
 ;   ALTER TABLE public.tb_alerts ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219    220            �           2604    16420    tb_markers id    DEFAULT     n   ALTER TABLE ONLY public.tb_markers ALTER COLUMN id SET DEFAULT nextval('public.tb_markers_id_seq'::regclass);
 <   ALTER TABLE public.tb_markers ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222            �           2604    16429    tb_occurrence_logs id_log    DEFAULT     �   ALTER TABLE ONLY public.tb_occurrence_logs ALTER COLUMN id_log SET DEFAULT nextval('public.tb_occurrence_logs_id_log_seq'::regclass);
 H   ALTER TABLE public.tb_occurrence_logs ALTER COLUMN id_log DROP DEFAULT;
       public          postgres    false    224    223    224            �           2604    16401    tb_occurrences id    DEFAULT     v   ALTER TABLE ONLY public.tb_occurrences ALTER COLUMN id SET DEFAULT nextval('public.tb_occurrences_id_seq'::regclass);
 @   ALTER TABLE public.tb_occurrences ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    16389    tb_users id    DEFAULT     j   ALTER TABLE ONLY public.tb_users ALTER COLUMN id SET DEFAULT nextval('public.tb_users_id_seq'::regclass);
 :   ALTER TABLE public.tb_users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215    216            S          0    16445    alert_notifications_log 
   TABLE DATA           _   COPY public.alert_notifications_log (log_id, alert_id, notification_time, message) FROM stdin;
    public          postgres    false    226   PF       M          0    16408 	   tb_alerts 
   TABLE DATA           u   COPY public.tb_alerts (id, alert_radius, severity_level, alert_message, latitude, longitude, alert_time) FROM stdin;
    public          postgres    false    220   mF       O          0    16417 
   tb_markers 
   TABLE DATA           J   COPY public.tb_markers (id, latitude, longitude, description) FROM stdin;
    public          postgres    false    222   �F       Q          0    16426    tb_occurrence_logs 
   TABLE DATA           m   COPY public.tb_occurrence_logs (id_log, id_occurrence, old_status, new_status, change_timestamp) FROM stdin;
    public          postgres    false    224   �F       K          0    16398    tb_occurrences 
   TABLE DATA           r   COPY public.tb_occurrences (id, description, occurrence_type, date_time, latitude, longitude, status) FROM stdin;
    public          postgres    false    218   �F       I          0    16386    tb_users 
   TABLE DATA           T   COPY public.tb_users (id, email, password, user_type, name, cpf, phone) FROM stdin;
    public          postgres    false    216   �F       `           0    0 "   alert_notifications_log_log_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.alert_notifications_log_log_id_seq', 1, false);
          public          postgres    false    225            a           0    0    tb_alerts_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.tb_alerts_id_seq', 1, false);
          public          postgres    false    219            b           0    0    tb_markers_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.tb_markers_id_seq', 1, false);
          public          postgres    false    221            c           0    0    tb_occurrence_logs_id_log_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.tb_occurrence_logs_id_log_seq', 1, false);
          public          postgres    false    223            d           0    0    tb_occurrences_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.tb_occurrences_id_seq', 1, false);
          public          postgres    false    217            e           0    0    tb_users_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.tb_users_id_seq', 1, false);
          public          postgres    false    215            �           2606    16452 4   alert_notifications_log alert_notifications_log_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.alert_notifications_log
    ADD CONSTRAINT alert_notifications_log_pkey PRIMARY KEY (log_id);
 ^   ALTER TABLE ONLY public.alert_notifications_log DROP CONSTRAINT alert_notifications_log_pkey;
       public            postgres    false    226            �           2606    16415    tb_alerts tb_alerts_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.tb_alerts
    ADD CONSTRAINT tb_alerts_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.tb_alerts DROP CONSTRAINT tb_alerts_pkey;
       public            postgres    false    220            �           2606    16424    tb_markers tb_markers_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.tb_markers
    ADD CONSTRAINT tb_markers_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.tb_markers DROP CONSTRAINT tb_markers_pkey;
       public            postgres    false    222            �           2606    16432 *   tb_occurrence_logs tb_occurrence_logs_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.tb_occurrence_logs
    ADD CONSTRAINT tb_occurrence_logs_pkey PRIMARY KEY (id_log);
 T   ALTER TABLE ONLY public.tb_occurrence_logs DROP CONSTRAINT tb_occurrence_logs_pkey;
       public            postgres    false    224            �           2606    16406 "   tb_occurrences tb_occurrences_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tb_occurrences
    ADD CONSTRAINT tb_occurrences_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.tb_occurrences DROP CONSTRAINT tb_occurrences_pkey;
       public            postgres    false    218            �           2606    16392    tb_users tb_users_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.tb_users
    ADD CONSTRAINT tb_users_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.tb_users DROP CONSTRAINT tb_users_pkey;
       public            postgres    false    216            �           2620    16453 +   tb_alerts check_severity_and_notify_trigger    TRIGGER     �   CREATE TRIGGER check_severity_and_notify_trigger AFTER INSERT ON public.tb_alerts FOR EACH ROW EXECUTE FUNCTION public.check_severity_and_notify();
 D   DROP TRIGGER check_severity_and_notify_trigger ON public.tb_alerts;
       public          postgres    false    220    230            �           2620    16442     tb_alerts set_alert_time_trigger    TRIGGER        CREATE TRIGGER set_alert_time_trigger BEFORE INSERT ON public.tb_alerts FOR EACH ROW EXECUTE FUNCTION public.set_alert_time();
 9   DROP TRIGGER set_alert_time_trigger ON public.tb_alerts;
       public          postgres    false    229    220            �           2620    16439 .   tb_occurrences tr_log_occurrence_status_change    TRIGGER     �   CREATE TRIGGER tr_log_occurrence_status_change BEFORE UPDATE ON public.tb_occurrences FOR EACH ROW EXECUTE FUNCTION public.log_occurrence_status_change();
 G   DROP TRIGGER tr_log_occurrence_status_change ON public.tb_occurrences;
       public          postgres    false    218    227            �           2606    16433 8   tb_occurrence_logs tb_occurrence_logs_id_occurrence_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tb_occurrence_logs
    ADD CONSTRAINT tb_occurrence_logs_id_occurrence_fkey FOREIGN KEY (id_occurrence) REFERENCES public.tb_occurrences(id);
 b   ALTER TABLE ONLY public.tb_occurrence_logs DROP CONSTRAINT tb_occurrence_logs_id_occurrence_fkey;
       public          postgres    false    218    3244    224            S      x������ � �      M      x������ � �      O      x������ � �      Q      x������ � �      K      x������ � �      I      x������ � �     