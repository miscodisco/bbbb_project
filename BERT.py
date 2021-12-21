#!/usr/bin/env python
# coding: utf-8


import numpy as np
import pandas as pd
import multiprocessing as mp

from time import process_time
from pysentimiento import create_analyzer
from pysentimiento.preprocessing import preprocess_tweet


def add_columns(df, res_matrix):
    """ Add columns to a data frame """ 
    df["preprocessed_text"] = res_matrix[0]
    df["sentiment_classification"] = res_matrix[1]
    df["sentiment_scores"] = res_matrix[2]
    df["emotion_classification"] = res_matrix[3]
    df["emotion_scores"] = res_matrix[4]

    return df


def analyze_tweets(df):
    """ Apply sentiment and emotional analysis to tweets in a data frame """

    t1_start = process_time()
    preprocessed = []
    sentiment = []
    sentiment_probas = []
    emotion = []
    emotion_probas = []

    analyzer = create_analyzer(task="sentiment", lang="en")
    emotion_analyzer = create_analyzer(task="emotion", lang="en")

    for index, row in df.iterrows():
        preprocessed_text = preprocess_tweet(str(row["texts"]))
        preprocessed.append(preprocessed_text)

        sentiment_prediction = analyzer.predict(preprocessed_text)
        sentiment.append(sentiment_prediction.output)
        sentiment_probas.append(sentiment_prediction.probas)

        emotion_prediction = emotion_analyzer.predict(preprocessed_text)
        emotion.append(emotion_prediction.output)
        emotion_probas.append(emotion_prediction.probas)

    df = add_columns(df, [preprocessed, sentiment, sentiment_probas, emotion, emotion_probas])
    t1_end = process_time()
    print(f"Chunk processing took {(t1_end-t1_start):.2f} seconds.")

    return df


def analyze_tweets_parallel(df):
    """ Split the data frame in chunks and start parallel analysis """
    df_split = np.array_split(df, mp.cpu_count())
    pool = mp.Pool(mp.cpu_count())
    df = pd.concat(pool.map(analyze_tweets, df_split))
    pool.close()
    pool.join()
    
    return df 
     

def sentiment_analysis(file, parallel=True):
    """ Envoke sentiment analysis and write results to a result csv """
    print(f"Loading {file}.")
    df = pd.read_csv(file)
    df = analyze_tweets_parallel(df) if parallel else analyze_tweets(df) # use parallel vs non-parallel function

    file_prefix = file.replace(".csv", "")
    output = f"{file_prefix}_sentiment.csv"
    print(f"Writing data frame to {output}.")
    df.to_csv(output, index=False)


def main():
    # analyse tweets 
    sentiment_analysis("df_music.csv")
    sentiment_analysis("df_non.csv")

    # df_non.head(20)
    # print(df_non["emotion_classification"].value_counts())
    # print(df_non["sentiment_classification"].value_counts())
    #
    # df_music.head(20)
    # print(df_music["emotion_classification"].value_counts())
    # print(df_music["sentiment_classification"].value_counts())


if __name__ == "__main__":
    main()
