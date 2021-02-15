# language: ru

Функциональность: Настройка конфигурации прекоммита

Как разработчик
Я хочу иметь возможность изменять настройки precommit4onec
Чтобы автоматически выполнять обработку исходников перед фиксацией изменений в репозитории

Сценарий: Печать текущих настроек precommit4onec
	Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os configure -global"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "precommit4onec v1.22.1"
		И Вывод команды "oscript" содержит "Установленные настройки:"
		И Вывод команды "oscript" содержит "ИспользоватьСценарииРепозитория ="
		И Вывод команды "oscript" содержит "КаталогЛокальныхСценариев ="
		И Вывод команды "oscript" содержит "ГлобальныеСценарии ="
		И Вывод команды "oscript" содержит "НастройкиСценариев ="

Сценарий: Сброс настроек, не должен приводить к удалению других настроек
	Когда я создаю временный каталог и запоминаю его как "КаталогРепозиториев"
		И я переключаюсь во временный каталог "КаталогРепозиториев"
		И я создаю новый репозиторий без инициализации "rep1" в каталоге "КаталогРепозиториев" и запоминаю его как "РабочийКаталог"
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install rep1"
		И я установил рабочий каталог как текущий каталог
		И Я копирую файл "tests\fixtures\ХранениеРазныхНастроек\v8config.json" в каталог репозитория "rep1"
		И я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os configure -rep-path . -reset"
	Тогда Файл "v8config.json" в рабочем каталоге содержит "GLOBAL"


Сценарий: Сброс настроек к значениям по умолчанию
	Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os configure -global -reset"
	Тогда Код возврата команды "oscript" равен 0
		И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os configure -global"
		И Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит
		"""
    precommit4onec v1.22.1
    Установленные настройки: Базовые настройки
        ИспользоватьСценарииРепозитория = Нет
        КаталогЛокальныхСценариев =
        ГлобальныеСценарии = ДобавлениеПробеловПередКлючевымиСловами.os,ЗапретИспользованияПерейти.os,ИсправлениеНеКаноническогоНаписания.os,КорректировкаXMLФорм.os,ОбработкаЮнитТестов.os,ОтключениеПолнотекстовогоПоиска.os,ПроверкаДублейПроцедурИФункций.os,ПроверкаКорректностиДирективКомпиляции.os,ПроверкаКорректностиОбластей.os,ПроверкаНецензурныхСлов.os,РазборОбычныхФормНаИсходники.os,РазборОтчетовОбработокРасширений.os,СинхронизацияОбъектовМетаданныхИФайлов.os,СортировкаДереваМетаданных.os,УдалениеДублейМетаданных.os,УдалениеЛишнихКонцевыхПробелов.os,УдалениеЛишнихПустыхСтрок.os
        ОтключенныеСценарии =
        НастройкиСценариев = Соответствие
                ОтключениеПолнотекстовогоПоиска = Соответствие
                        МетаданныеДляИсключения = Соответствие
                                src\_example.xml = Номер,ТабличнаяЧасть1.Реквизит
                                src\_example2.xml =
				ПроверкаНецензурныхСлов = Соответствие
                               ФайлСНецензурнымиСловами = НецензурныеСлова.txt
                РазборОтчетовОбработокРасширений = Соответствие
                        ИспользоватьНастройкиПоУмолчанию = Да
                        ВерсияПлатформы =
		"""
