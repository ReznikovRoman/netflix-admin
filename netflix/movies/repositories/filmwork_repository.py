from django.contrib.postgres.aggregates import ArrayAgg
from django.db.models import F, Q, QuerySet

from netflix.movies.models import Filmwork, PersonRole


class FilmworkRepository:
    """Репозиторий для работы с данными кинопроизведений."""

    @staticmethod
    def get_filmworks_with_related_data() -> QuerySet[Filmwork]:
        filmworks_data = (
            Filmwork.objects
            .annotate(
                genres_list=ArrayAgg("genres__name", distinct=True),
                actors_list=ArrayAgg(
                    "persons__full_name", filter=Q(personfilmwork__role=PersonRole.ACTOR.value), distinct=True),
                directors_list=ArrayAgg(
                    "persons__full_name", filter=Q(personfilmwork__role=PersonRole.DIRECTOR.value), distinct=True),
                writers_list=ArrayAgg(
                    "persons__full_name", filter=Q(personfilmwork__role=PersonRole.WRITER.value), distinct=True),
            )
            .values(
                "id", "title", "description", "creation_date", "rating", "type",
            )
            .annotate(
                genres=F("genres_list"),
                actors=F("actors_list"),
                directors=F("directors_list"),
                writers=F("writers_list"),
            )
        )
        return filmworks_data
