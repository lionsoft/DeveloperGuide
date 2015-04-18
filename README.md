**1.** По умолчанию **`WebApi`**-контроллеры **`Web`**-приложения, роутинг которых настроен так, чтобы передавать параметры
   в адресе запроса, не умеют получать строковые параметры, содержащие точку.

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

----------

**2.** По умолчанию методы **`WebApi`**-контроллеров не наследуются, т.е. нельзя описать **`Web`**-метод в родительском классе, чтобы он вызывался из дочернего.
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

----------

**3.** По умолчанию из папки **`~/Views`** и её подпапок нельзя загружать скрипты и стили, чтобы это исправить необходимо в файле **`web.config`**, который лежит в папке **`~/Views`** перед строчкой  

    <add name="BlockViewHandler" path="*" verb="*" preCondition="integratedMode" type="System.Web.HttpNotFoundHandler" />
   
добавить строки

    <add name="JavaScript" path="*.js" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="TypeScriptScript" path="*.ts" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="TypeScriptMap" path="*.js.map" verb="GET,HEAD" type="System.Web.StaticFileHandler" />
    <add name="CSS" path="*.css" verb="GET,HEAD" type="System.Web.StaticFileHandler" />

Подробнее:
http://stackoverflow.com/questions/604883/where-to-put-view-specific-javascript-files-in-an-asp-net-mvc-application

----------

**4.** По умолчанию **`TypeScript`**-файлы не деплоятся на сервер, но нам нужно, чтобы они присутствовали, т.к. **`bundles.RegisterViewsScripts()`** автоматически   добавляет в бандлы представлений только **`js`**-файлы, рядом с которыми лежат соответствующие **`ts`**-файлы.
   Чтобы включить деплой **`TypeScript`**-файлов необходимо в **`.csproj`** файл в раздел **`<Project>`** добавить следующий код: 

    <Target Name="AddTsToContent" AfterTargets="CompileTypeScript" Condition="'$(BuildingProject)' != 'false'">
       <ItemGroup>
           <Content Include="@(TypeScriptCompile)" />
       </ItemGroup>
    </Target>

Подробнее:
http://stackoverflow.com/questions/24322063/how-to-include-typescript-files-when-publishing

----------

**5.** По умолчанию в **VS2013** **`TypeScript`**-файлы неправильно компилируются в **`.js`** при **СОХРАНЕНИИ** в студии (не при билде). В частности члены **`enum`**'ов, описанные в **`.d.ts`** файле, подставляются как есть, а не в виде чисел.
   Чтобы это исправить, необходимо заменить файл **`<ProgramFilesx86>\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TypeScript\typescriptServices.js`**
   на этот https://dl.dropboxusercontent.com/u/14232632/typescriptServices.js.

Подробнее:
https://github.com/Microsoft/TypeScript/issues/1812#issuecomment-71576781
