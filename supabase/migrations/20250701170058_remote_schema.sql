create table "public"."achievements" (
    "badge_id" text not null,
    "user_id" uuid not null,
    "unlocked_at" timestamp with time zone default timezone('utc'::text, now())
);


create table "public"."answers" (
    "id" uuid not null default gen_random_uuid(),
    "question_id" uuid,
    "answer_text" text not null,
    "is_correct" boolean not null default false
);


create table "public"."comment_likes" (
    "user_id" uuid not null,
    "comment_id" uuid not null,
    "liked_at" timestamp with time zone not null default now()
);


create table "public"."comments" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "skill_id" uuid,
    "content" text not null,
    "created_at" timestamp with time zone default timezone('utc'::text, now()),
    "parent_comment_id" uuid
);


create table "public"."favorites" (
    "user_id" uuid not null,
    "skill_id" uuid not null,
    "saved_at" timestamp with time zone default timezone('utc'::text, now())
);


alter table "public"."favorites" enable row level security;

create table "public"."follows" (
    "follower_id" uuid not null,
    "followed_id" uuid not null,
    "followed_at" timestamp with time zone default timezone('utc'::text, now())
);


create table "public"."likes" (
    "user_id" uuid not null,
    "skill_id" uuid not null,
    "liked_at" timestamp with time zone default timezone('utc'::text, now())
);


alter table "public"."likes" enable row level security;

create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "type" text not null,
    "data" jsonb,
    "is_read" boolean not null default false,
    "created_at" timestamp with time zone default timezone('utc'::text, now())
);


create table "public"."profiles" (
    "id" uuid not null,
    "username" text,
    "display_name" text,
    "avatar_url" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."profiles" enable row level security;

create table "public"."questions" (
    "id" uuid not null default gen_random_uuid(),
    "quiz_id" uuid,
    "question_text" text not null,
    "order_index" integer not null
);


create table "public"."quizzes" (
    "id" uuid not null default gen_random_uuid(),
    "skill_id" uuid,
    "title" text,
    "created_at" timestamp with time zone default timezone('utc'::text, now())
);


create table "public"."responses" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "quiz_id" uuid,
    "question_id" uuid,
    "answer_id" uuid,
    "responded_at" timestamp with time zone default timezone('utc'::text, now())
);


create table "public"."skill_bookmarks" (
    "id" uuid not null default gen_random_uuid(),
    "skill_id" uuid,
    "user_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."skill_bookmarks" enable row level security;

create table "public"."skill_comments" (
    "id" uuid not null default gen_random_uuid(),
    "skill_id" uuid,
    "user_id" uuid,
    "comment" text not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."skill_comments" enable row level security;

create table "public"."skill_likes" (
    "id" uuid not null default gen_random_uuid(),
    "skill_id" uuid,
    "user_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."skill_likes" enable row level security;

create table "public"."skill_shares" (
    "id" uuid not null default gen_random_uuid(),
    "skill_id" uuid,
    "user_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."skill_shares" enable row level security;

create table "public"."skills" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "description" text,
    "video_url" text not null,
    "thumbnail_url" text,
    "category" text,
    "creator_id" uuid,
    "view_count" integer not null default 0,
    "created_at" timestamp with time zone default timezone('utc'::text, now()),
    "music_title" text,
    "music_artist" text,
    "like_count" integer not null default 0,
    "tags" text[]
);


alter table "public"."skills" enable row level security;

create table "public"."user_follows" (
    "id" uuid not null default gen_random_uuid(),
    "follower_id" uuid,
    "following_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."user_follows" enable row level security;

create table "public"."users" (
    "id" uuid not null,
    "name" text,
    "avatar_url" text,
    "bio" text,
    "role" text not null default 'learner'::text,
    "created_at" timestamp with time zone default timezone('utc'::text, now()),
    "username" text not null
);


create table "public"."views" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "skill_id" uuid,
    "viewed_at" timestamp with time zone default timezone('utc'::text, now())
);


alter table "public"."views" enable row level security;

CREATE UNIQUE INDEX achievements_pkey ON public.achievements USING btree (badge_id, user_id);

CREATE UNIQUE INDEX answers_pkey ON public.answers USING btree (id);

CREATE UNIQUE INDEX comment_likes_pkey ON public.comment_likes USING btree (user_id, comment_id);

CREATE UNIQUE INDEX comments_pkey ON public.comments USING btree (id);

CREATE UNIQUE INDEX favorites_pkey ON public.favorites USING btree (user_id, skill_id);

CREATE UNIQUE INDEX follows_pkey ON public.follows USING btree (follower_id, followed_id);

CREATE INDEX idx_comments_parent_id ON public.comments USING btree (parent_comment_id);

CREATE INDEX idx_comments_skill_id ON public.comments USING btree (skill_id);

CREATE INDEX idx_favorites_user_id ON public.favorites USING btree (user_id);

CREATE INDEX idx_likes_skill_id ON public.likes USING btree (skill_id);

CREATE INDEX idx_views_skill_id ON public.views USING btree (skill_id);

CREATE UNIQUE INDEX likes_pkey ON public.likes USING btree (user_id, skill_id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX profiles_username_key ON public.profiles USING btree (username);

CREATE UNIQUE INDEX questions_pkey ON public.questions USING btree (id);

CREATE UNIQUE INDEX quizzes_pkey ON public.quizzes USING btree (id);

CREATE UNIQUE INDEX responses_pkey ON public.responses USING btree (id);

CREATE UNIQUE INDEX skill_bookmarks_pkey ON public.skill_bookmarks USING btree (id);

CREATE UNIQUE INDEX skill_bookmarks_skill_id_user_id_key ON public.skill_bookmarks USING btree (skill_id, user_id);

CREATE UNIQUE INDEX skill_comments_pkey ON public.skill_comments USING btree (id);

CREATE UNIQUE INDEX skill_likes_pkey ON public.skill_likes USING btree (id);

CREATE UNIQUE INDEX skill_likes_skill_id_user_id_key ON public.skill_likes USING btree (skill_id, user_id);

CREATE UNIQUE INDEX skill_shares_pkey ON public.skill_shares USING btree (id);

CREATE UNIQUE INDEX skill_shares_skill_id_user_id_key ON public.skill_shares USING btree (skill_id, user_id);

CREATE UNIQUE INDEX skills_pkey ON public.skills USING btree (id);

CREATE UNIQUE INDEX user_follows_follower_id_following_id_key ON public.user_follows USING btree (follower_id, following_id);

CREATE UNIQUE INDEX user_follows_pkey ON public.user_follows USING btree (id);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);

CREATE UNIQUE INDEX views_pkey ON public.views USING btree (id);

alter table "public"."achievements" add constraint "achievements_pkey" PRIMARY KEY using index "achievements_pkey";

alter table "public"."answers" add constraint "answers_pkey" PRIMARY KEY using index "answers_pkey";

alter table "public"."comment_likes" add constraint "comment_likes_pkey" PRIMARY KEY using index "comment_likes_pkey";

alter table "public"."comments" add constraint "comments_pkey" PRIMARY KEY using index "comments_pkey";

alter table "public"."favorites" add constraint "favorites_pkey" PRIMARY KEY using index "favorites_pkey";

alter table "public"."follows" add constraint "follows_pkey" PRIMARY KEY using index "follows_pkey";

alter table "public"."likes" add constraint "likes_pkey" PRIMARY KEY using index "likes_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."questions" add constraint "questions_pkey" PRIMARY KEY using index "questions_pkey";

alter table "public"."quizzes" add constraint "quizzes_pkey" PRIMARY KEY using index "quizzes_pkey";

alter table "public"."responses" add constraint "responses_pkey" PRIMARY KEY using index "responses_pkey";

alter table "public"."skill_bookmarks" add constraint "skill_bookmarks_pkey" PRIMARY KEY using index "skill_bookmarks_pkey";

alter table "public"."skill_comments" add constraint "skill_comments_pkey" PRIMARY KEY using index "skill_comments_pkey";

alter table "public"."skill_likes" add constraint "skill_likes_pkey" PRIMARY KEY using index "skill_likes_pkey";

alter table "public"."skill_shares" add constraint "skill_shares_pkey" PRIMARY KEY using index "skill_shares_pkey";

alter table "public"."skills" add constraint "skills_pkey" PRIMARY KEY using index "skills_pkey";

alter table "public"."user_follows" add constraint "user_follows_pkey" PRIMARY KEY using index "user_follows_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."views" add constraint "views_pkey" PRIMARY KEY using index "views_pkey";

alter table "public"."achievements" add constraint "achievements_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."achievements" validate constraint "achievements_user_id_fkey";

alter table "public"."answers" add constraint "answers_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE not valid;

alter table "public"."answers" validate constraint "answers_question_id_fkey";

alter table "public"."comment_likes" add constraint "comment_likes_comment_id_fkey" FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE not valid;

alter table "public"."comment_likes" validate constraint "comment_likes_comment_id_fkey";

alter table "public"."comment_likes" add constraint "comment_likes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."comment_likes" validate constraint "comment_likes_user_id_fkey";

alter table "public"."comments" add constraint "comments_parent_comment_id_fkey" FOREIGN KEY (parent_comment_id) REFERENCES comments(id) ON DELETE CASCADE not valid;

alter table "public"."comments" validate constraint "comments_parent_comment_id_fkey";

alter table "public"."comments" add constraint "comments_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."comments" validate constraint "comments_skill_id_fkey";

alter table "public"."comments" add constraint "comments_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."comments" validate constraint "comments_user_id_fkey";

alter table "public"."favorites" add constraint "favorites_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."favorites" validate constraint "favorites_skill_id_fkey";

alter table "public"."favorites" add constraint "favorites_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."favorites" validate constraint "favorites_user_id_fkey";

alter table "public"."follows" add constraint "follows_followed_id_fkey" FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."follows" validate constraint "follows_followed_id_fkey";

alter table "public"."follows" add constraint "follows_follower_id_fkey" FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."follows" validate constraint "follows_follower_id_fkey";

alter table "public"."likes" add constraint "likes_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."likes" validate constraint "likes_skill_id_fkey";

alter table "public"."likes" add constraint "likes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."likes" validate constraint "likes_user_id_fkey";

alter table "public"."notifications" add constraint "notifications_type_check" CHECK ((type = ANY (ARRAY['new_comment'::text, 'new_follower'::text, 'reply'::text, 'trending_skill'::text]))) not valid;

alter table "public"."notifications" validate constraint "notifications_type_check";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_username_key" UNIQUE using index "profiles_username_key";

alter table "public"."questions" add constraint "questions_quiz_id_fkey" FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE not valid;

alter table "public"."questions" validate constraint "questions_quiz_id_fkey";

alter table "public"."quizzes" add constraint "quizzes_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."quizzes" validate constraint "quizzes_skill_id_fkey";

alter table "public"."responses" add constraint "responses_answer_id_fkey" FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE SET NULL not valid;

alter table "public"."responses" validate constraint "responses_answer_id_fkey";

alter table "public"."responses" add constraint "responses_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE not valid;

alter table "public"."responses" validate constraint "responses_question_id_fkey";

alter table "public"."responses" add constraint "responses_quiz_id_fkey" FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE not valid;

alter table "public"."responses" validate constraint "responses_quiz_id_fkey";

alter table "public"."responses" add constraint "responses_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE not valid;

alter table "public"."responses" validate constraint "responses_user_id_fkey";

alter table "public"."skill_bookmarks" add constraint "skill_bookmarks_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."skill_bookmarks" validate constraint "skill_bookmarks_skill_id_fkey";

alter table "public"."skill_bookmarks" add constraint "skill_bookmarks_skill_id_user_id_key" UNIQUE using index "skill_bookmarks_skill_id_user_id_key";

alter table "public"."skill_bookmarks" add constraint "skill_bookmarks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."skill_bookmarks" validate constraint "skill_bookmarks_user_id_fkey";

alter table "public"."skill_comments" add constraint "skill_comments_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."skill_comments" validate constraint "skill_comments_skill_id_fkey";

alter table "public"."skill_comments" add constraint "skill_comments_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."skill_comments" validate constraint "skill_comments_user_id_fkey";

alter table "public"."skill_likes" add constraint "skill_likes_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."skill_likes" validate constraint "skill_likes_skill_id_fkey";

alter table "public"."skill_likes" add constraint "skill_likes_skill_id_user_id_key" UNIQUE using index "skill_likes_skill_id_user_id_key";

alter table "public"."skill_likes" add constraint "skill_likes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."skill_likes" validate constraint "skill_likes_user_id_fkey";

alter table "public"."skill_shares" add constraint "skill_shares_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."skill_shares" validate constraint "skill_shares_skill_id_fkey";

alter table "public"."skill_shares" add constraint "skill_shares_skill_id_user_id_key" UNIQUE using index "skill_shares_skill_id_user_id_key";

alter table "public"."skill_shares" add constraint "skill_shares_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."skill_shares" validate constraint "skill_shares_user_id_fkey";

alter table "public"."skills" add constraint "skills_creator_id_fkey" FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL not valid;

alter table "public"."skills" validate constraint "skills_creator_id_fkey";

alter table "public"."user_follows" add constraint "user_follows_follower_id_fkey" FOREIGN KEY (follower_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_follows" validate constraint "user_follows_follower_id_fkey";

alter table "public"."user_follows" add constraint "user_follows_follower_id_following_id_key" UNIQUE using index "user_follows_follower_id_following_id_key";

alter table "public"."user_follows" add constraint "user_follows_following_id_fkey" FOREIGN KEY (following_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_follows" validate constraint "user_follows_following_id_fkey";

alter table "public"."users" add constraint "users_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."users" validate constraint "users_id_fkey";

alter table "public"."users" add constraint "users_role_check" CHECK ((role = ANY (ARRAY['learner'::text, 'creator'::text]))) not valid;

alter table "public"."users" validate constraint "users_role_check";

alter table "public"."users" add constraint "users_username_key" UNIQUE using index "users_username_key";

alter table "public"."views" add constraint "views_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE not valid;

alter table "public"."views" validate constraint "views_skill_id_fkey";

alter table "public"."views" add constraint "views_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL not valid;

alter table "public"."views" validate constraint "views_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'display_name');
  RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_skill_view_count()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  update skills set view_count = view_count + 1 where id = new.skill_id;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_new_comment()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  creator uuid;
begin
  select creator_id into creator from skills where id = new.skill_id;
  if creator is not null and creator != new.user_id then
    insert into notifications (user_id, type, data)
    values (creator, 'new_comment', jsonb_build_object('skill_id', new.skill_id, 'comment_id', new.id));
  end if;
  return new;
end;
$function$
;

grant delete on table "public"."achievements" to "anon";

grant insert on table "public"."achievements" to "anon";

grant references on table "public"."achievements" to "anon";

grant select on table "public"."achievements" to "anon";

grant trigger on table "public"."achievements" to "anon";

grant truncate on table "public"."achievements" to "anon";

grant update on table "public"."achievements" to "anon";

grant delete on table "public"."achievements" to "authenticated";

grant insert on table "public"."achievements" to "authenticated";

grant references on table "public"."achievements" to "authenticated";

grant select on table "public"."achievements" to "authenticated";

grant trigger on table "public"."achievements" to "authenticated";

grant truncate on table "public"."achievements" to "authenticated";

grant update on table "public"."achievements" to "authenticated";

grant delete on table "public"."achievements" to "service_role";

grant insert on table "public"."achievements" to "service_role";

grant references on table "public"."achievements" to "service_role";

grant select on table "public"."achievements" to "service_role";

grant trigger on table "public"."achievements" to "service_role";

grant truncate on table "public"."achievements" to "service_role";

grant update on table "public"."achievements" to "service_role";

grant delete on table "public"."answers" to "anon";

grant insert on table "public"."answers" to "anon";

grant references on table "public"."answers" to "anon";

grant select on table "public"."answers" to "anon";

grant trigger on table "public"."answers" to "anon";

grant truncate on table "public"."answers" to "anon";

grant update on table "public"."answers" to "anon";

grant delete on table "public"."answers" to "authenticated";

grant insert on table "public"."answers" to "authenticated";

grant references on table "public"."answers" to "authenticated";

grant select on table "public"."answers" to "authenticated";

grant trigger on table "public"."answers" to "authenticated";

grant truncate on table "public"."answers" to "authenticated";

grant update on table "public"."answers" to "authenticated";

grant delete on table "public"."answers" to "service_role";

grant insert on table "public"."answers" to "service_role";

grant references on table "public"."answers" to "service_role";

grant select on table "public"."answers" to "service_role";

grant trigger on table "public"."answers" to "service_role";

grant truncate on table "public"."answers" to "service_role";

grant update on table "public"."answers" to "service_role";

grant delete on table "public"."comment_likes" to "anon";

grant insert on table "public"."comment_likes" to "anon";

grant references on table "public"."comment_likes" to "anon";

grant select on table "public"."comment_likes" to "anon";

grant trigger on table "public"."comment_likes" to "anon";

grant truncate on table "public"."comment_likes" to "anon";

grant update on table "public"."comment_likes" to "anon";

grant delete on table "public"."comment_likes" to "authenticated";

grant insert on table "public"."comment_likes" to "authenticated";

grant references on table "public"."comment_likes" to "authenticated";

grant select on table "public"."comment_likes" to "authenticated";

grant trigger on table "public"."comment_likes" to "authenticated";

grant truncate on table "public"."comment_likes" to "authenticated";

grant update on table "public"."comment_likes" to "authenticated";

grant delete on table "public"."comment_likes" to "service_role";

grant insert on table "public"."comment_likes" to "service_role";

grant references on table "public"."comment_likes" to "service_role";

grant select on table "public"."comment_likes" to "service_role";

grant trigger on table "public"."comment_likes" to "service_role";

grant truncate on table "public"."comment_likes" to "service_role";

grant update on table "public"."comment_likes" to "service_role";

grant delete on table "public"."comments" to "anon";

grant insert on table "public"."comments" to "anon";

grant references on table "public"."comments" to "anon";

grant select on table "public"."comments" to "anon";

grant trigger on table "public"."comments" to "anon";

grant truncate on table "public"."comments" to "anon";

grant update on table "public"."comments" to "anon";

grant delete on table "public"."comments" to "authenticated";

grant insert on table "public"."comments" to "authenticated";

grant references on table "public"."comments" to "authenticated";

grant select on table "public"."comments" to "authenticated";

grant trigger on table "public"."comments" to "authenticated";

grant truncate on table "public"."comments" to "authenticated";

grant update on table "public"."comments" to "authenticated";

grant delete on table "public"."comments" to "service_role";

grant insert on table "public"."comments" to "service_role";

grant references on table "public"."comments" to "service_role";

grant select on table "public"."comments" to "service_role";

grant trigger on table "public"."comments" to "service_role";

grant truncate on table "public"."comments" to "service_role";

grant update on table "public"."comments" to "service_role";

grant delete on table "public"."favorites" to "anon";

grant insert on table "public"."favorites" to "anon";

grant references on table "public"."favorites" to "anon";

grant select on table "public"."favorites" to "anon";

grant trigger on table "public"."favorites" to "anon";

grant truncate on table "public"."favorites" to "anon";

grant update on table "public"."favorites" to "anon";

grant delete on table "public"."favorites" to "authenticated";

grant insert on table "public"."favorites" to "authenticated";

grant references on table "public"."favorites" to "authenticated";

grant select on table "public"."favorites" to "authenticated";

grant trigger on table "public"."favorites" to "authenticated";

grant truncate on table "public"."favorites" to "authenticated";

grant update on table "public"."favorites" to "authenticated";

grant delete on table "public"."favorites" to "service_role";

grant insert on table "public"."favorites" to "service_role";

grant references on table "public"."favorites" to "service_role";

grant select on table "public"."favorites" to "service_role";

grant trigger on table "public"."favorites" to "service_role";

grant truncate on table "public"."favorites" to "service_role";

grant update on table "public"."favorites" to "service_role";

grant delete on table "public"."follows" to "anon";

grant insert on table "public"."follows" to "anon";

grant references on table "public"."follows" to "anon";

grant select on table "public"."follows" to "anon";

grant trigger on table "public"."follows" to "anon";

grant truncate on table "public"."follows" to "anon";

grant update on table "public"."follows" to "anon";

grant delete on table "public"."follows" to "authenticated";

grant insert on table "public"."follows" to "authenticated";

grant references on table "public"."follows" to "authenticated";

grant select on table "public"."follows" to "authenticated";

grant trigger on table "public"."follows" to "authenticated";

grant truncate on table "public"."follows" to "authenticated";

grant update on table "public"."follows" to "authenticated";

grant delete on table "public"."follows" to "service_role";

grant insert on table "public"."follows" to "service_role";

grant references on table "public"."follows" to "service_role";

grant select on table "public"."follows" to "service_role";

grant trigger on table "public"."follows" to "service_role";

grant truncate on table "public"."follows" to "service_role";

grant update on table "public"."follows" to "service_role";

grant delete on table "public"."likes" to "anon";

grant insert on table "public"."likes" to "anon";

grant references on table "public"."likes" to "anon";

grant select on table "public"."likes" to "anon";

grant trigger on table "public"."likes" to "anon";

grant truncate on table "public"."likes" to "anon";

grant update on table "public"."likes" to "anon";

grant delete on table "public"."likes" to "authenticated";

grant insert on table "public"."likes" to "authenticated";

grant references on table "public"."likes" to "authenticated";

grant select on table "public"."likes" to "authenticated";

grant trigger on table "public"."likes" to "authenticated";

grant truncate on table "public"."likes" to "authenticated";

grant update on table "public"."likes" to "authenticated";

grant delete on table "public"."likes" to "service_role";

grant insert on table "public"."likes" to "service_role";

grant references on table "public"."likes" to "service_role";

grant select on table "public"."likes" to "service_role";

grant trigger on table "public"."likes" to "service_role";

grant truncate on table "public"."likes" to "service_role";

grant update on table "public"."likes" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."questions" to "anon";

grant insert on table "public"."questions" to "anon";

grant references on table "public"."questions" to "anon";

grant select on table "public"."questions" to "anon";

grant trigger on table "public"."questions" to "anon";

grant truncate on table "public"."questions" to "anon";

grant update on table "public"."questions" to "anon";

grant delete on table "public"."questions" to "authenticated";

grant insert on table "public"."questions" to "authenticated";

grant references on table "public"."questions" to "authenticated";

grant select on table "public"."questions" to "authenticated";

grant trigger on table "public"."questions" to "authenticated";

grant truncate on table "public"."questions" to "authenticated";

grant update on table "public"."questions" to "authenticated";

grant delete on table "public"."questions" to "service_role";

grant insert on table "public"."questions" to "service_role";

grant references on table "public"."questions" to "service_role";

grant select on table "public"."questions" to "service_role";

grant trigger on table "public"."questions" to "service_role";

grant truncate on table "public"."questions" to "service_role";

grant update on table "public"."questions" to "service_role";

grant delete on table "public"."quizzes" to "anon";

grant insert on table "public"."quizzes" to "anon";

grant references on table "public"."quizzes" to "anon";

grant select on table "public"."quizzes" to "anon";

grant trigger on table "public"."quizzes" to "anon";

grant truncate on table "public"."quizzes" to "anon";

grant update on table "public"."quizzes" to "anon";

grant delete on table "public"."quizzes" to "authenticated";

grant insert on table "public"."quizzes" to "authenticated";

grant references on table "public"."quizzes" to "authenticated";

grant select on table "public"."quizzes" to "authenticated";

grant trigger on table "public"."quizzes" to "authenticated";

grant truncate on table "public"."quizzes" to "authenticated";

grant update on table "public"."quizzes" to "authenticated";

grant delete on table "public"."quizzes" to "service_role";

grant insert on table "public"."quizzes" to "service_role";

grant references on table "public"."quizzes" to "service_role";

grant select on table "public"."quizzes" to "service_role";

grant trigger on table "public"."quizzes" to "service_role";

grant truncate on table "public"."quizzes" to "service_role";

grant update on table "public"."quizzes" to "service_role";

grant delete on table "public"."responses" to "anon";

grant insert on table "public"."responses" to "anon";

grant references on table "public"."responses" to "anon";

grant select on table "public"."responses" to "anon";

grant trigger on table "public"."responses" to "anon";

grant truncate on table "public"."responses" to "anon";

grant update on table "public"."responses" to "anon";

grant delete on table "public"."responses" to "authenticated";

grant insert on table "public"."responses" to "authenticated";

grant references on table "public"."responses" to "authenticated";

grant select on table "public"."responses" to "authenticated";

grant trigger on table "public"."responses" to "authenticated";

grant truncate on table "public"."responses" to "authenticated";

grant update on table "public"."responses" to "authenticated";

grant delete on table "public"."responses" to "service_role";

grant insert on table "public"."responses" to "service_role";

grant references on table "public"."responses" to "service_role";

grant select on table "public"."responses" to "service_role";

grant trigger on table "public"."responses" to "service_role";

grant truncate on table "public"."responses" to "service_role";

grant update on table "public"."responses" to "service_role";

grant delete on table "public"."skill_bookmarks" to "anon";

grant insert on table "public"."skill_bookmarks" to "anon";

grant references on table "public"."skill_bookmarks" to "anon";

grant select on table "public"."skill_bookmarks" to "anon";

grant trigger on table "public"."skill_bookmarks" to "anon";

grant truncate on table "public"."skill_bookmarks" to "anon";

grant update on table "public"."skill_bookmarks" to "anon";

grant delete on table "public"."skill_bookmarks" to "authenticated";

grant insert on table "public"."skill_bookmarks" to "authenticated";

grant references on table "public"."skill_bookmarks" to "authenticated";

grant select on table "public"."skill_bookmarks" to "authenticated";

grant trigger on table "public"."skill_bookmarks" to "authenticated";

grant truncate on table "public"."skill_bookmarks" to "authenticated";

grant update on table "public"."skill_bookmarks" to "authenticated";

grant delete on table "public"."skill_bookmarks" to "service_role";

grant insert on table "public"."skill_bookmarks" to "service_role";

grant references on table "public"."skill_bookmarks" to "service_role";

grant select on table "public"."skill_bookmarks" to "service_role";

grant trigger on table "public"."skill_bookmarks" to "service_role";

grant truncate on table "public"."skill_bookmarks" to "service_role";

grant update on table "public"."skill_bookmarks" to "service_role";

grant delete on table "public"."skill_comments" to "anon";

grant insert on table "public"."skill_comments" to "anon";

grant references on table "public"."skill_comments" to "anon";

grant select on table "public"."skill_comments" to "anon";

grant trigger on table "public"."skill_comments" to "anon";

grant truncate on table "public"."skill_comments" to "anon";

grant update on table "public"."skill_comments" to "anon";

grant delete on table "public"."skill_comments" to "authenticated";

grant insert on table "public"."skill_comments" to "authenticated";

grant references on table "public"."skill_comments" to "authenticated";

grant select on table "public"."skill_comments" to "authenticated";

grant trigger on table "public"."skill_comments" to "authenticated";

grant truncate on table "public"."skill_comments" to "authenticated";

grant update on table "public"."skill_comments" to "authenticated";

grant delete on table "public"."skill_comments" to "service_role";

grant insert on table "public"."skill_comments" to "service_role";

grant references on table "public"."skill_comments" to "service_role";

grant select on table "public"."skill_comments" to "service_role";

grant trigger on table "public"."skill_comments" to "service_role";

grant truncate on table "public"."skill_comments" to "service_role";

grant update on table "public"."skill_comments" to "service_role";

grant delete on table "public"."skill_likes" to "anon";

grant insert on table "public"."skill_likes" to "anon";

grant references on table "public"."skill_likes" to "anon";

grant select on table "public"."skill_likes" to "anon";

grant trigger on table "public"."skill_likes" to "anon";

grant truncate on table "public"."skill_likes" to "anon";

grant update on table "public"."skill_likes" to "anon";

grant delete on table "public"."skill_likes" to "authenticated";

grant insert on table "public"."skill_likes" to "authenticated";

grant references on table "public"."skill_likes" to "authenticated";

grant select on table "public"."skill_likes" to "authenticated";

grant trigger on table "public"."skill_likes" to "authenticated";

grant truncate on table "public"."skill_likes" to "authenticated";

grant update on table "public"."skill_likes" to "authenticated";

grant delete on table "public"."skill_likes" to "service_role";

grant insert on table "public"."skill_likes" to "service_role";

grant references on table "public"."skill_likes" to "service_role";

grant select on table "public"."skill_likes" to "service_role";

grant trigger on table "public"."skill_likes" to "service_role";

grant truncate on table "public"."skill_likes" to "service_role";

grant update on table "public"."skill_likes" to "service_role";

grant delete on table "public"."skill_shares" to "anon";

grant insert on table "public"."skill_shares" to "anon";

grant references on table "public"."skill_shares" to "anon";

grant select on table "public"."skill_shares" to "anon";

grant trigger on table "public"."skill_shares" to "anon";

grant truncate on table "public"."skill_shares" to "anon";

grant update on table "public"."skill_shares" to "anon";

grant delete on table "public"."skill_shares" to "authenticated";

grant insert on table "public"."skill_shares" to "authenticated";

grant references on table "public"."skill_shares" to "authenticated";

grant select on table "public"."skill_shares" to "authenticated";

grant trigger on table "public"."skill_shares" to "authenticated";

grant truncate on table "public"."skill_shares" to "authenticated";

grant update on table "public"."skill_shares" to "authenticated";

grant delete on table "public"."skill_shares" to "service_role";

grant insert on table "public"."skill_shares" to "service_role";

grant references on table "public"."skill_shares" to "service_role";

grant select on table "public"."skill_shares" to "service_role";

grant trigger on table "public"."skill_shares" to "service_role";

grant truncate on table "public"."skill_shares" to "service_role";

grant update on table "public"."skill_shares" to "service_role";

grant delete on table "public"."skills" to "anon";

grant insert on table "public"."skills" to "anon";

grant references on table "public"."skills" to "anon";

grant select on table "public"."skills" to "anon";

grant trigger on table "public"."skills" to "anon";

grant truncate on table "public"."skills" to "anon";

grant update on table "public"."skills" to "anon";

grant delete on table "public"."skills" to "authenticated";

grant insert on table "public"."skills" to "authenticated";

grant references on table "public"."skills" to "authenticated";

grant select on table "public"."skills" to "authenticated";

grant trigger on table "public"."skills" to "authenticated";

grant truncate on table "public"."skills" to "authenticated";

grant update on table "public"."skills" to "authenticated";

grant delete on table "public"."skills" to "service_role";

grant insert on table "public"."skills" to "service_role";

grant references on table "public"."skills" to "service_role";

grant select on table "public"."skills" to "service_role";

grant trigger on table "public"."skills" to "service_role";

grant truncate on table "public"."skills" to "service_role";

grant update on table "public"."skills" to "service_role";

grant delete on table "public"."user_follows" to "anon";

grant insert on table "public"."user_follows" to "anon";

grant references on table "public"."user_follows" to "anon";

grant select on table "public"."user_follows" to "anon";

grant trigger on table "public"."user_follows" to "anon";

grant truncate on table "public"."user_follows" to "anon";

grant update on table "public"."user_follows" to "anon";

grant delete on table "public"."user_follows" to "authenticated";

grant insert on table "public"."user_follows" to "authenticated";

grant references on table "public"."user_follows" to "authenticated";

grant select on table "public"."user_follows" to "authenticated";

grant trigger on table "public"."user_follows" to "authenticated";

grant truncate on table "public"."user_follows" to "authenticated";

grant update on table "public"."user_follows" to "authenticated";

grant delete on table "public"."user_follows" to "service_role";

grant insert on table "public"."user_follows" to "service_role";

grant references on table "public"."user_follows" to "service_role";

grant select on table "public"."user_follows" to "service_role";

grant trigger on table "public"."user_follows" to "service_role";

grant truncate on table "public"."user_follows" to "service_role";

grant update on table "public"."user_follows" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";

grant delete on table "public"."views" to "anon";

grant insert on table "public"."views" to "anon";

grant references on table "public"."views" to "anon";

grant select on table "public"."views" to "anon";

grant trigger on table "public"."views" to "anon";

grant truncate on table "public"."views" to "anon";

grant update on table "public"."views" to "anon";

grant delete on table "public"."views" to "authenticated";

grant insert on table "public"."views" to "authenticated";

grant references on table "public"."views" to "authenticated";

grant select on table "public"."views" to "authenticated";

grant trigger on table "public"."views" to "authenticated";

grant truncate on table "public"."views" to "authenticated";

grant update on table "public"."views" to "authenticated";

grant delete on table "public"."views" to "service_role";

grant insert on table "public"."views" to "service_role";

grant references on table "public"."views" to "service_role";

grant select on table "public"."views" to "service_role";

grant trigger on table "public"."views" to "service_role";

grant truncate on table "public"."views" to "service_role";

grant update on table "public"."views" to "service_role";

create policy "Allow delete for authenticated users"
on "public"."favorites"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Allow insert for authenticated users"
on "public"."favorites"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Allow select for authenticated users"
on "public"."favorites"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Allow all actions for authenticated"
on "public"."likes"
as permissive
for all
to public
using ((auth.uid() IS NOT NULL));


create policy "Allow select for authenticated"
on "public"."likes"
as permissive
for select
to public
using ((auth.uid() IS NOT NULL));


create policy "Users can insert their own profile"
on "public"."profiles"
as permissive
for insert
to public
with check ((auth.uid() = id));


create policy "Users can update their own profile"
on "public"."profiles"
as permissive
for update
to public
using ((auth.uid() = id));


create policy "Users can view all profiles"
on "public"."profiles"
as permissive
for select
to public
using (true);


create policy "Users can delete their own bookmarks"
on "public"."skill_bookmarks"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own bookmarks"
on "public"."skill_bookmarks"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can view their own bookmarks"
on "public"."skill_bookmarks"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can delete their own comments"
on "public"."skill_comments"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own comments"
on "public"."skill_comments"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own comments"
on "public"."skill_comments"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view all comments"
on "public"."skill_comments"
as permissive
for select
to public
using (true);


create policy "Users can delete their own likes"
on "public"."skill_likes"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own likes"
on "public"."skill_likes"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can view all likes"
on "public"."skill_likes"
as permissive
for select
to public
using (true);


create policy "Users can delete their own shares"
on "public"."skill_shares"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own shares"
on "public"."skill_shares"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can view all shares"
on "public"."skill_shares"
as permissive
for select
to public
using (true);


create policy "Allow public insert"
on "public"."skills"
as permissive
for insert
to public
with check (true);


create policy "Allow public read"
on "public"."skills"
as permissive
for select
to public
using (true);


create policy "Users can delete their own follows"
on "public"."user_follows"
as permissive
for delete
to public
using ((auth.uid() = follower_id));


create policy "Users can insert their own follows"
on "public"."user_follows"
as permissive
for insert
to public
with check ((auth.uid() = follower_id));


create policy "Users can view all follows"
on "public"."user_follows"
as permissive
for select
to public
using (true);


create policy "Allow authenticated insert"
on "public"."views"
as permissive
for insert
to public
with check ((auth.uid() IS NOT NULL));


create policy "Allow users to insert their own views"
on "public"."views"
as permissive
for insert
to authenticated
with check ((auth.uid() = user_id));


CREATE TRIGGER trg_notify_new_comment AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION notify_new_comment();

CREATE TRIGGER trg_increment_view_count AFTER INSERT ON public.views FOR EACH ROW EXECUTE FUNCTION increment_skill_view_count();


