using System;

class GoertzelFilterTest {
    static void Main(string[] args) 
    {
	var flt = new GoertzelFilter(2000, 8000);
	Console.WriteLine(flt);
	var samples = new double[] {0, 1, 0, -1};
	var y = flt.Process(samples);
	Console.WriteLine(flt);
	Console.WriteLine(y);
    }
}