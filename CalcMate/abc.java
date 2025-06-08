import java.util.Scanner;
public class abc {

    public static void main ( String []args){
        int max = -999999999 ;
        int arr[] = {-2, 0, 1};
        int n = arr.length;
    
        for(int i=0; i < n ; i++)
        {   
            for (int j = i + 1; j < n; j++) {
                int a = 0 ;
                if (i == 0 && j == 1) {

                    a = arr[i] * arr[j];
                    max = a;

                }
                else {
                    a *= arr[j];
                }
                if (max < a) {
                    max = a;
                }

            }
        }
        System.out.println(max);
    }
} 