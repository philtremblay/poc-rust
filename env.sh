export DATABASE_URL="postgres://poc:password@localhost:5432/poc_rust"
export ROCKET_DATABASES="{ rocket_app = { url = \"$DATABASE_URL\" } }"