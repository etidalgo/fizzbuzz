

namespace FizzBuzz.Iterators
{
    internal class BuzzGenerator : IGenerator
    {
        private int _current = 0;

        public void Seed(int start)
        {
            _current = (start % 5);
        }

        public void Reset()
        {
            _current = 0;
        }

        public string Next()
        {
            _current++;
            if (_current == 5)
            {
                _current = 0;
                return "Buzz";
            }
            return "";
        }
    }
}
