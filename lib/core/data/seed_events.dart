import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';

final List<EventModel> seedEvents = [
  EventModel(
    id: 'seed_1',
    title: 'Рок-фестиваль «Новая Волна»',
    description:
        'Ежегодный рок-фестиваль на ВДНХ. Выступления 12 групп, фуд-зона, мерч-ярмарка. Начало в 15:00, Главная сцена.',
    latitude: 55.8237,
    longitude: 37.6399,
    date: DateTime(2025, 7, 20, 15, 0),
    type: EventType.festival,
    venue: 'ВДНХ, Главная сцена',
  ),
  EventModel(
    id: 'seed_2',
    title: 'Джазовый вечер в парке',
    description:
        'Живой джаз под открытым небом. Вход свободный. Берите пледы и наслаждайтесь музыкой.',
    latitude: 55.7297,
    longitude: 37.6015,
    date: DateTime(2025, 7, 18, 19, 0),
    type: EventType.concert,
    venue: 'Парк Горького, Амфитеатр',
  ),
  EventModel(
    id: 'seed_3',
    title: 'Выставка современного искусства',
    description:
        '«Город и люди» — экспозиция из 200 работ 50 художников. Интерактивные инсталляции, мастер-классы.',
    latitude: 55.7525,
    longitude: 37.6233,
    date: DateTime(2025, 7, 15, 11, 0),
    type: EventType.exhibition,
    venue: 'Третьяковская галерея',
  ),
  EventModel(
    id: 'seed_4',
    title: 'Забег «Беги за Москвой»',
    description:
        '10 км по набережной Москвы-реки. Старт у Парка Победы. Медали всем финишёрам.',
    latitude: 55.7350,
    longitude: 37.5100,
    date: DateTime(2025, 7, 22, 8, 0),
    type: EventType.sport,
    venue: 'Парк Победы',
  ),
  EventModel(
    id: 'seed_5',
    title: 'Фермерский рынок на Даниловском',
    description:
        'Свежие продукты от 80 фермеров. Сыры, мёд, хлеб, овощи. Каждые выходные с 8:00 до 16:00.',
    latitude: 55.7090,
    longitude: 37.6320,
    date: DateTime(2025, 7, 19, 8, 0),
    type: EventType.market,
    venue: 'Даниловский рынок',
  ),
  EventModel(
    id: 'seed_6',
    title: 'IT-митап «Flutter Moscow»',
    description:
        'Доклады о Flutter, BLoC, Clean Architecture. Нетворкинг, пицца, стикеры. 3 спикера.',
    latitude: 55.7558,
    longitude: 37.5790,
    date: DateTime(2025, 7, 25, 19, 0),
    type: EventType.meetup,
    venue: 'Коворкинг «Точка», Арбат',
  ),
  EventModel(
    id: 'seed_7',
    title: 'Опера «Евгений Онегин»',
    description:
        'Постановка Большого театра. Начало в 19:00. Билеты от 1500 ₽.',
    latitude: 55.7601,
    longitude: 37.6186,
    date: DateTime(2025, 7, 28, 19, 0),
    type: EventType.concert,
    venue: 'Большой театр',
  ),
  EventModel(
    id: 'seed_8',
    title: 'Марафон «Красная Армия»',
    description:
        '42 км по историческому центру Москвы. Старт от Кремля, финиш на стадионе «Лужники».',
    latitude: 55.7539,
    longitude: 37.6208,
    date: DateTime(2025, 8, 3, 7, 0),
    type: EventType.sport,
    venue: 'Красная площадь → Лужники',
  ),
  EventModel(
    id: 'seed_9',
    title: 'Ночь музеев',
    description:
        'Более 200 музеев открыты бесплатно до 6 утра. Экскурсии, перформансы, шоу.',
    latitude: 55.7500,
    longitude: 37.6000,
    date: DateTime(2025, 8, 9, 18, 0),
    type: EventType.other,
    venue: 'Москва, все районы',
  ),
  EventModel(
    id: 'seed_10',
    title: 'Street Food Festival',
    description:
        'Фестиваль уличной еды: бургеры, рамен, тако, десерты. 40 точек, DJ-сеты, бар.',
    latitude: 55.7700,
    longitude: 37.5850,
    date: DateTime(2025, 7, 26, 12, 0),
    type: EventType.festival,
    venue: 'Красный Октябрь',
  ),
];
