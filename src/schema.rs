table! {
    pageviews (id) {
        id -> Int4,
        view_time -> Timestamptz,
        url -> Varchar,
        user_agent -> Varchar,
        referrer -> Varchar,
        device_type -> Int2,
    }
}
