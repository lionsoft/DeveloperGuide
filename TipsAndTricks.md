Передача параметров, содержащих точку, в **`WebApi`**-контроллеры **`Web`**-приложения
-------------------------------------------------------------------------------------- 

По умолчанию **`WebApi`**-контроллеры **`Web`**-приложения, роутинг которых настроен так, чтобы передавать параметры в адресе запроса, не умеют получать строковые параметры, содержащие точку.

Чтобы это исправить нужно указать в **`web.config`**:

    <configuration>
        <system.webServer>
            <handlers>
                <remove name="ExtensionlessUrlHandler-Integrated-4.0" />
                <add name="API-ExtensionlessUrlHandler-Integrated-4.0" path="api/*" verb="*" type="System.Web.Handlers.TransferRequestHandler" preCondition="integratedMode,runtimeVersionv4.0" />
                <add name="ExtensionlessUrlHandler-Integrated-4.0" path="*." verb="*" type="System.Web.Handlers.TransferRequestHandler" preCondition="integratedMode,runtimeVersionv4.0" />
            </handlers>
   
Подробнее:
http://habrahabr.ru/post/254525

Там же описано почему **ПЛОХО**:
   
    <configuration>
        <system.webServer>
            <modules runAllManagedModulesForAllRequests="true" />

описанное в 
http://stackoverflow.com/questions/20998816/dot-character-in-mvc-web-api-2-for-request-such-as-api-people-staff-45287

Наследование методов **`WebApi`**-контроллеров
----------------------------------------------

По умолчанию методы **`WebApi`**-контроллеров не наследуются, т.е. нельзя описать **`Web`**-метод в родительском классе, чтобы он вызывался из дочернего.

Чтобы это исправить нужно указать в **`WebApiConfig.cs`**:

    config.MapHttpAttributeRoutes(new CustomDirectRouteProvider());

    //---------

    public class CustomDirectRouteProvider : DefaultDirectRouteProvider
    {
        protected override IReadOnlyList<IDirectRouteFactory> 
        GetActionRouteFactories(HttpActionDescriptor actionDescriptor)
        {
            // inherit route attributes decorated on base class controller's actions
            return actionDescriptor.GetCustomAttributes<IDirectRouteFactory>
            (inherit: true);
        }
    }

Подробнее:
http://stackoverflow.com/questions/19989023/net-webapi-attribute-routing-and-inheritance


Загрузка скриптов и стилей из папки **`~/Views`**
-------------------------------------------------

По умолчанию из папки **`~/Views`** и её подпапок нельзя загружать скрипты и стили, чтобы это исправить необходимо в файле **`web.config`**, который лежит в папке **`~/Views`** перед строчкой  

    <add name="BlockViewHandler" path="*" verb="*" preCondition="integratedMode" type="System.Web.HttpNotFoundHandler" />
   
добавить строки

    <add name="JavaScript" path="*.js" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="TypeScriptScript" path="*.ts" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="TypeScriptMap" path="*.js.map" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="CSS" path="*.css" verb="GET,HEAD" type="System.Web.StaticFileHandler" />

Подробнее:
http://stackoverflow.com/questions/604883/where-to-put-view-specific-javascript-files-in-an-asp-net-mvc-application


Деплой **`TypeScript`**-файлы на сервер
---------------------------------------

По умолчанию **`TypeScript`**-файлы не деплоятся на сервер, но нам нужно, чтобы они присутствовали, т.к. **`bundles.RegisterViewsScripts()`** автоматически добавляет в бандлы представлений только **`js`**-файлы, рядом с которыми лежат соответствующие **`ts`**-файлы.
Чтобы включить деплой **`TypeScript`**-файлов необходимо в **`.csproj`** файл в раздел **`<Project>`** добавить следующий код: 

    <Target Name="AddTsToContent" AfterTargets="CompileTypeScript" Condition="'$(BuildingProject)' != 'false'">
       <ItemGroup>
           <Content Include="@(TypeScriptCompile)" />
       </ItemGroup>
    </Target>

Подробнее:
http://stackoverflow.com/questions/24322063/how-to-include-typescript-files-when-publishing


Фикс компиляции **`TypeScript`**-файлов в редакторе студии
---------------------------------------------------------- 
По умолчанию в **VS2013** **`TypeScript`**-файлы неправильно компилируются в **`.js`** при **СОХРАНЕНИИ** в студии (не при билде). В частности члены **`enum`**'ов, описанные в **`.d.ts`** файле, подставляются как есть, а не в виде чисел.

Чтобы это исправить, необходимо заменить файл 
**`<ProgramFilesx86>\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TypeScript\typescriptServices.js`**
на этот 
https://dl.dropboxusercontent.com/u/14232632/typescriptServices.js.

Подробнее:
https://github.com/Microsoft/TypeScript/issues/1812#issuecomment-71576781


Включение миграций
------------------

1. Выполните команду `Enable-Migrations –EnableAutomaticMigrations` в консоли диспетчера пакетов. При этом в наш проект добавляется папка `Migrations`. Эта новая папка содержит класс `Configuration`. Данный класс позволяет настроить поведение `Migrations` в контексте.
Если в проекте имеется только один контекст `Code First`, `Enable-Migrations` автоматически заполняет тип контекста, к которому применяется эта конфигурация.
В `Code First Migrations` имеется две команды, которые будут сейчас представлены:
`Update-Database` - применяет все отложенные изменения к базе данных.
`Add-Migration` - формирует на основе скаффолдинга следующую миграцию, исходя из внесенных в модель изменений.
Постарайтесь избегать использования `Add-Migration` (если только это не будет действительно необходимо) 
и позвольте `Code First Migrations` автоматически рассчитывать и применять изменения. 
        
2. Выполните команду `Update-Database` в консоли диспетчера пакетов.
При этом `Code First Migrations` явно обновит базу данных, внеся изменения, сделанные в модели с момента последнего обновления БД. 
Если этого не сделать - обновление пройдёт при открытии БД.

3. Если необходима ручная доработка модели - необходимо выполнить ручную миграцию, выполнив команду `Add-Migration` <имя миграции>.

4. Параметры класса `Configuration`:
`AutomaticMigrationsEnabled` - явное разрешение/запрещение автоматических миграций
`AutomaticMigrationDataLossAllowed` - явное разрешение/запрещение автоматических миграций с потерей данных
`MigrationsDirectory` - относительный относительно каталога проекта каталог в котором будут помещены автоматически сгенерированные файлы ручных миграций
`MigrationsNamespace` - пространство имён для автоматически сгенерированных классов ручных миграций

Подробнее:
Команды миграции: http://coding.abel.nu/2012/03/ef-migrations-command-reference/


Как исключить папку с NuGet-пакетами из TFS
-------------------------------------------

Подробнее:
http://www.xavierdecoster.com/post/2011/10/17/tell-tfs-not-to-add-nuget-packages-to-source-control
https://msdn.microsoft.com/en-us/library/ms181378.aspx?f=255&MSPPError=-2147217396


Работа с табличными данными в Web-Аpplication
---------------------------------------------

Для работы с табличными данными в `Web-Application` используем: [angular-datatables](http://l-lin.github.io/angular-datatables/ "angular-datatables") с [ODATA-коннектором](https://github.com/vpllan/jQuery.dataTables.oData/).

Подробнее:
http://l-lin.github.io/angular-datatables/
https://github.com/vpllan/jQuery.dataTables.oData/


Использование самоподписанных сертификатов
---------------------------------------------

Чтобы можно было использовать `WebAPI` интерфейс по `HTTPS` протоколу с самоподписанным сертификатом на клиенте нужно прописать:

	ServicePointManager.ServerCertificateValidationCallback += (sender, cert, chain, sslPolicyErrors) => true;

Подробнее:
http://stackoverflow.com/questions/12553277/allowing-untrusted-ssl-certificates-with-httpclient


Как объединить все сборки проекта в один файл
---------------------------------------------

Для объединения всех сборок проекта в один файл нужно воспользоваться `ILMerge`.

Подробнее:
http://habrahabr.ru/post/126089/
