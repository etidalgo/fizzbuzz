namespace FizzBuzz
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");

            var datetimeStamp = DateTime.Now.ToString("yyyyMMdd HHmmss");
            File.Copy("./appsettings.json", $"c:/temp/appsettings.{datetimeStamp}.json");
            File.Copy("./flux.appsettings.json", $"c:/temp/flux.appsettings.{datetimeStamp}.json");

            var gens = new Iterators.IGenerator[] { new Iterators.FizzGenerator(), new Iterators.BuzzGenerator() };
            Enumerable.Range(1, 100).ToList().ForEach(i =>
            {
                Console.WriteLine(i.ToString() + string.Join(" ", gens.Select(g => g.Next())));
            });
        }
    }
}