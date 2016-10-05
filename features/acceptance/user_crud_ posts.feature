# language: ru

  Функционал: Создание поста авторизованным пользователем
    Я как пользователь
    Хочу создавать, редактировать, удалять посты
    Чтобы предоставлять своевременно информацию от имени организации

  @login @logout
  Сценарий: Создание поста, редактирование и удаление.
    Допустим я на странице создания поста
    И ввожу в поле "Title" текст "Тестовый заголовок"
    И выбираю из списка "Нужна помощь" в поле "post_post_category_id"
    И ввожу в поле "Body" текст "Тестовый текст поста"
    И кликаю на кнопку "Опубликовать"
    Тогда должен увидеть текст "Текстовый заголовок"
    И кликаю на ссылку "Редактировать"
    И ввожу в поле "Title" текст "Тестовый заголовок2"
    И выбираю из списка "Благодарность" в поле "post_post_category_id"
    И ввожу в поле "Body" текст "Тестовый текст поста2"
    И кликаю на кнопку "Опубликовать"
    Тогда должен увидеть текст "Текстовый заголовок2"
    И кликаю на ссылку "Удалить"
    И кликаю на алерт "Ок"
    Допустим перехожу "/posts"
    И должен не найти "Текстовый заголовок"