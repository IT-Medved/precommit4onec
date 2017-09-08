///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов 
// "РазборОтчетовОбработокРасширений"
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать v8runner

Перем Лог;

///////////////////////////////////////////////////////////////////////////////
// Стандартный программный интерфейс
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "РазборОтчетовОбработокРасширений";

КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализиремыйАнализируемыйФайлФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образоавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;

	Если ТипФайлаПоддерживается(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		КаталогВыгрузки = ПодготовитьКаталогВыгрузки(КаталогИсходныхФайлов, АнализируемыйФайл, ДополнительныеПараметры);
		Если Не АнализируемыйФайл.Существует() Тогда

			Возврат ИСТИНА;

		КонецЕсли;
		
		Если СтрСравнить(АнализируемыйФайл.Расширение, ".cfe") <> 0 Тогда
			
			РаспаковатьОтчетОбработку(АнализируемыйФайл, КаталогВыгрузки);

		Иначе

			РаспаковатьРасширение(АнализируемыйФайл, КаталогВыгрузки);

		КонецЕсли;
		
		// Добавим файлы для дальнейшей обработки
		// Понятно, что добавить удаленные не получится
		ФайлыВКаталогеТВФ = НайтиФайлы(КаталогВыгрузки, "*", ИСТИНА);
		Для каждого ФайлВКателогеТВФ Из ФайлыВКаталогеТВФ Цикл
			
			ДополнительныеПараметры.ФайлыДляПостОбработки.Добавить(ФайлВКателогеТВФ.ПолноеИмя);

		КонецЦикла;

		Возврат ИСТИНА;

	КонецЕсли;

	Возврат ЛОЖЬ;

КонецФункции // ОбработатьФайл()

///////////////////////////////////////////////////////////////////////////////

Функция ПодготовитьКаталогВыгрузки(КаталогИсходныхФайлов, ОбрабатываемыйФайл, ДополнительныеПараметры)
	
	ФайлУдален = НЕ ОбрабатываемыйФайл.Существует();

	СоставПутиФайл = СтрРазделить(ОбрабатываемыйФайл.Путь, ПолучитьРазделительПути());
	СоставПутиКаталогИсходныхФайлов = СтрРазделить(КаталогИсходныхФайлов, ПолучитьРазделительПути());
	ИмяКаталогаВыгрузки = ОбрабатываемыйФайл.ИмяБезРасширения;
	Для Ит = 0 По Мин(СоставПутиКаталогИсходныхФайлов.Количество(), СоставПутиФайл.Количество()) - 1 Цикл
	
		Если СтрСравнить(СоставПутиФайл[Ит], СоставПутиКаталогИсходныхФайлов[Ит]) = 0 Тогда

			Продолжить;

		КонецЕсли;
	
		Пока Ит > 0 Цикл
		
			СоставПутиФайл.Удалить(0);
			Ит = Ит - 1;

		КонецЦикла;

		ИмяКаталогаВыгрузки = СтрСоединить(СоставПутиФайл, ПолучитьРазделительПути());
		Прервать;

	КонецЦикла;

	Если ИмяКаталогаВыгрузки <> ОбрабатываемыйФайл.ИмяБезРасширения Тогда

		ИмяКаталогаВыгрузки = ОбъединитьПути(ИмяКаталогаВыгрузки, ОбрабатываемыйФайл.ИмяБезРасширения);

	КонецЕсли;
	
	КаталогТекущегоВнешнегоФайла = ОбъединитьПути(КаталогИсходныхФайлов, Сред(НРег(ОбрабатываемыйФайл.Расширение), 2), ИмяКаталогаВыгрузки);
	ФайлКаталогТекущегоВнешнегоФайла = Новый Файл(КаталогТекущегоВнешнегоФайла);
	Если НЕ ФайлКаталогТекущегоВнешнегоФайла.Существует() Тогда

		Если ФайлУдален Тогда

			КаталогТекущегоВнешнегоФайла = "";

		Иначе

			СоздатьКаталог(КаталогТекущегоВнешнегоФайла);

		КонецЕсли;

	Иначе

		ФайлыВКаталогеТВФ = НайтиФайлы(КаталогТекущегоВнешнегоФайла, "*", ИСТИНА);
		Для каждого ФайлВКателогеТВФ Из ФайлыВКаталогеТВФ Цикл
		
			Если НЕ ФайлВКателогеТВФ.Существует() Тогда
			
				Продолжить;

			КонецЕсли;

			УдалитьФайлы(ФайлВКателогеТВФ.ПолноеИмя);

		КонецЦикла;

		Если ФайлУдален Тогда

			УдалитьФайлы(КаталогТекущегоВнешнегоФайла);

		КонецЕсли;

	КонецЕсли;

	Если НЕ ПустаяСтрока(КаталогТекущегоВнешнегоФайла) Тогда

		ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(КаталогТекущегоВнешнегоФайла);

	КонецЕсли;

	Если Не ФайлУдален Тогда

		Возврат КаталогТекущегоВнешнегоФайла;

	КонецЕсли;

	Возврат "";
	
КонецФункции // ПодготовитьКаталогВыгрузки()

Функция ТипФайлаПоддерживается(Файл)

	Если ПустаяСтрока(Файл.Расширение) Тогда

		Возврат Ложь;

	КонецЕсли;

	Поз = Найти(".epf,.erf,.cfe,", НРег(Файл.Расширение + ","));
	Возврат Поз > 0;

КонецФункции

Процедура РаспаковатьОтчетОбработку(Знач Файл, Знач КаталогВыгрузки)
	
	Лог.Отладка("Распаковка файла внешнего отчета обработки %1", Файл.ПолноеИмя);
	
	Конфигуратор = ПодготовитьКонфигуратор();	

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Параметры.Добавить("/DumpExternalDataProcessorOrReportToFiles");
	Параметры.Добавить(СтрШаблон("%1", КаталогВыгрузки));
	Параметры.Добавить(СтрШаблон("%1", Файл.ПолноеИмя));
	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());
	
КонецПроцедуры

Процедура РаспаковатьРасширение(Знач Файл, Знач КаталогВыгрузки)
	
	Лог.Отладка("Распаковка файла расширения %1", Файл.ПолноеИмя);
	
	ИмяРасширения = Файл.ИмяБезРасширения;
	Конфигуратор = ПодготовитьКонфигуратор();	
	
	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Параметры.Добавить(СтрШаблон("/LoadCfg ""%1""", Файл.ПолноеИмя));
	Параметры.Добавить(СтрШаблон("-Extension %1", ИмяРасширения));
	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());
	
	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Параметры.Добавить(СтрШаблон("/DumpConfigToFiles ""%1""", КаталогВыгрузки));
	Параметры.Добавить(СтрШаблон("-Extension %1", ИмяРасширения));
	Конфигуратор.ВыполнитьКоманду(Параметры);
	Лог.Отладка("Вывод 1С:Предприятия - " + Конфигуратор.ВыводКоманды());

КонецПроцедуры

Функция ПодготовитьКонфигуратор()
	
	Конфигуратор = Новый УправлениеКонфигуратором();
	КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
	Конфигуратор.КаталогСборки(КаталогВременнойИБ);
	
	ЛогКонфигуратора = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	ЛогКонфигуратора.УстановитьУровень(Лог.Уровень());
	ЛогКонфигуратора.Закрыть();

	Возврат Конфигуратор;

КонецФункции // ПодготовитьКонфигуратор()
