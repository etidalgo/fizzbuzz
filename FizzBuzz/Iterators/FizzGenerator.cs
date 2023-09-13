
namespace FizzBuzz.Iterators
{
    internal class FizzGenerator: IGenerator
    {
        private int _current = 0;

        public void Seed(int start)
        {
            _current = (start % 3);
        }

        public void Reset()
        {
            _current = 0;
        }

        public string Next()
        {
            _current++;
            if (_current == 3)
            {
                _current = 0;
                return "Fizz";
            }
            return "";
        }
    }
}
