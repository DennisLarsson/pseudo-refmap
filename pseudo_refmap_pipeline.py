import argparse
import subprocess

def make_reference_index(reference, threads):
    subprocess.run(["bwa", "index", "-p", reference, "-a", "bwtsw", reference], check=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Pseudo-reference mapping pipeline")
    parser.add_argument("-r", "--reference", help="Reference genome file", required=True)
    parser.add_argument("-o", "--output", help="Output directory", required=True)
    parser.add_argument("-s", "--samples", help="Samples folder", required=True)
    parser.add_argument("-t", "--threads", help="Number of threads", required=True)
    parser.add_argument("-p", "--popmap", help="Population map file", required=True)